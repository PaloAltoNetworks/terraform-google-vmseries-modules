locals {
  secret = random_id.secret.b64_url

  tunnels_tmp = flatten([
    for vpn_instance_name, vpn_instance_config in var.vpn_config.instances : [
      for tunnel_name, tunnel_config in vpn_instance_config.tunnels : {
        tunnel_name = "${vpn_instance_name}-${tunnel_name}"
        tunnel_config = merge(
          tunnel_config,
          {
            vpn_instance_name     = vpn_instance_name
            peer_external_gateway = try(vpn_instance_config.peer_external_gateway, null)
            peer_gcp_gateway      = try(vpn_instance_config.peer_gcp_gateway, null)
          }
        )
      }
    ]
  ])

  tunnels = {
    for k, v in local.tunnels_tmp : v.tunnel_name => v.tunnel_config
  }
}

resource "google_compute_ha_vpn_gateway" "ha_gateway" {
  name    = var.vpn_gateway_name
  project = var.project
  region  = var.region
  network = var.network
}

resource "google_compute_router" "router" {
  name    = coalesce(var.router_name, "${var.vpn_gateway_name}-rtr")
  project = var.project
  region  = var.region
  network = var.network
  bgp {
    advertise_mode = (
      var.vpn_config.router_advertise_config == null
      ? null
      : var.vpn_config.router_advertise_config.mode
    )
    advertised_groups = (
      var.vpn_config.router_advertise_config == null ? null : (
        var.vpn_config.router_advertise_config.mode != "CUSTOM"
        ? null
        : var.vpn_config.router_advertise_config.groups
      )
    )
    dynamic "advertised_ip_ranges" {
      for_each = (
        var.vpn_config.router_advertise_config == null ? {} : (
          var.vpn_config.router_advertise_config.mode != "CUSTOM"
          ? {}
          : var.vpn_config.router_advertise_config.ip_ranges
        )
      )
      iterator = range
      content {
        range       = range.key
        description = range.value
      }
    }
    asn                = var.vpn_config.router_asn
    keepalive_interval = try(var.vpn_config.keepalive_interval, 20)
  }
}

# Represents a VPN gateway managed outside of GCP
resource "google_compute_external_vpn_gateway" "external_gateway" {
  for_each = { for k, v in var.vpn_config.instances : k => v if try(v.peer_external_gateway, null) != null }

  name            = try(each.value.peer_external_gateway.name, null) != null ? each.value.peer_external_gateway.name : "${each.value.name}-external-gw"
  project         = var.project
  redundancy_type = each.value.peer_external_gateway.redundancy_type
  description     = try(each.value.external_vpn_gateway_description, null)
  labels          = var.labels
  dynamic "interface" {
    for_each = each.value.peer_external_gateway.interfaces
    content {
      id         = interface.value.id
      ip_address = interface.value.ip_address
    }
  }
}

resource "google_compute_router_peer" "bgp_peer" {
  for_each        = local.tunnels
  region          = var.region
  project         = var.project
  name            = try(each.value.bgp_session_name, null) != null ? each.value.bgp_session_name : "${var.vpn_gateway_name}-${each.key}"
  router          = google_compute_router.router.name
  peer_ip_address = each.value.bgp_peer.address
  peer_asn        = each.value.bgp_peer.asn
  ip_address      = each.value.bgp_peer_options == null ? null : each.value.bgp_peer_options.ip_address
  advertised_route_priority = (
    each.value.bgp_peer_options == null ? try(each.value.route_priority, 1000) : (
      each.value.bgp_peer_options.route_priority == null
      ? each.value.route_priority
      : each.value.bgp_peer_options.route_priority
    )
  )
  advertise_mode = (
    each.value.bgp_peer_options == null ? null : each.value.bgp_peer_options.advertise_mode
  )
  advertised_groups = (
    each.value.bgp_peer_options == null ? null : (
      each.value.bgp_peer_options.advertise_mode != "CUSTOM"
      ? null
      : each.value.bgp_peer_options.advertise_groups
    )
  )
  dynamic "advertised_ip_ranges" {
    for_each = (
      each.value.bgp_peer_options == null ? {} : (
        each.value.bgp_peer_options.advertise_mode != "CUSTOM"
        ? {}
        : each.value.bgp_peer_options.advertise_ip_ranges
      )
    )
    iterator = range
    content {
      range       = range.key
      description = range.value
    }
  }
  interface = google_compute_router_interface.router_interface[each.key].name
}

resource "google_compute_router_interface" "router_interface" {
  for_each   = local.tunnels
  project    = var.project
  region     = var.region
  name       = try(each.value.bgp_session_name, null) != null ? each.value.bgp_session_name : each.key
  router     = google_compute_router.router.name
  ip_range   = each.value.bgp_session_range == "" ? null : each.value.bgp_session_range
  vpn_tunnel = google_compute_vpn_tunnel.tunnels[each.key].name
}

resource "google_compute_vpn_tunnel" "tunnels" {
  provider                        = google-beta
  for_each                        = local.tunnels
  project                         = var.project
  region                          = var.region
  name                            = "${var.vpn_gateway_name}-${each.key}"
  router                          = google_compute_router.router.name
  peer_external_gateway           = try(google_compute_external_vpn_gateway.external_gateway[each.value.vpn_instance_name].self_link, null)
  peer_external_gateway_interface = each.value.peer_external_gateway_interface
  peer_gcp_gateway                = each.value.peer_gcp_gateway
  vpn_gateway_interface           = each.value.vpn_gateway_interface
  ike_version                     = each.value.ike_version
  shared_secret                   = each.value.shared_secret == "" ? local.secret : each.value.shared_secret
  vpn_gateway                     = google_compute_ha_vpn_gateway.ha_gateway.self_link
  labels                          = var.labels
}

resource "random_id" "secret" {
  byte_length = 16
}
