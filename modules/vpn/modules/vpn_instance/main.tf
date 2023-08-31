locals {
  peer_external_gateway = (
    var.peer_external_gateway != null
    ? google_compute_external_vpn_gateway.external_gateway[0].self_link
    : null
  )
  secret = random_id.secret.b64_url
}

resource "google_compute_router" "router" {
  name    = coalesce(var.router_name, "rtr-${var.name}")
  project = var.project
  region  = var.region
  network = var.network
  bgp {
    advertise_mode = (
      var.router_advertise_config == null
      ? null
      : var.router_advertise_config.mode
    )
    advertised_groups = (
      var.router_advertise_config == null ? null : (
        var.router_advertise_config.mode != "CUSTOM"
        ? null
        : var.router_advertise_config.groups
      )
    )
    dynamic "advertised_ip_ranges" {
      for_each = (
        var.router_advertise_config == null ? {} : (
          var.router_advertise_config.mode != "CUSTOM"
          ? {}
          : var.router_advertise_config.ip_ranges
        )
      )
      iterator = range
      content {
        range       = range.key
        description = range.value
      }
    }
    asn                = var.router_asn
    keepalive_interval = var.keepalive_interval
  }
}

resource "google_compute_external_vpn_gateway" "external_gateway" {
  count           = var.peer_external_gateway != null ? 1 : 0
  name            = try(var.peer_external_gateway.name, null) != null ? var.peer_external_gateway.name : "external-${var.name}"
  project         = var.project
  redundancy_type = var.peer_external_gateway.redundancy_type
  description     = var.external_vpn_gateway_description
  labels          = var.labels
  dynamic "interface" {
    for_each = var.peer_external_gateway.interfaces
    content {
      id         = interface.value.id
      ip_address = interface.value.ip_address
    }
  }
}

resource "google_compute_router_peer" "bgp_peer" {
  for_each        = var.tunnels
  region          = var.region
  project         = var.project
  name            = try(each.value.bgp_session_name, null) != null ? each.value.bgp_session_name : "${var.name}-${each.key}"
  router          = google_compute_router.router.name
  peer_ip_address = each.value.bgp_peer.address
  peer_asn        = each.value.bgp_peer.asn
  ip_address      = each.value.bgp_peer_options == null ? null : each.value.bgp_peer_options.ip_address
  advertised_route_priority = (
    each.value.bgp_peer_options == null ? var.route_priority : (
      each.value.bgp_peer_options.route_priority == null
      ? var.route_priority
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
  for_each   = var.tunnels
  project    = var.project
  region     = var.region
  name       = try(each.value.bgp_session_name, null) != null ? each.value.bgp_session_name : "${var.name}-${each.key}"
  router     = google_compute_router.router.name
  ip_range   = each.value.bgp_session_range == "" ? null : each.value.bgp_session_range
  vpn_tunnel = google_compute_vpn_tunnel.tunnels[each.key].name
}

resource "google_compute_vpn_tunnel" "tunnels" {
  provider                        = google-beta
  for_each                        = var.tunnels
  project                         = var.project
  region                          = var.region
  name                            = "${var.name}-${each.key}"
  router                          = google_compute_router.router.name
  peer_external_gateway           = local.peer_external_gateway
  peer_external_gateway_interface = each.value.peer_external_gateway_interface
  peer_gcp_gateway                = var.peer_gcp_gateway
  vpn_gateway_interface           = each.value.vpn_gateway_interface
  ike_version                     = each.value.ike_version
  shared_secret                   = each.value.shared_secret == "" ? local.secret : each.value.shared_secret
  vpn_gateway                     = var.vpn_gateway_self_link
  labels                          = var.labels
}

resource "random_id" "secret" {
  byte_length = 16
}
