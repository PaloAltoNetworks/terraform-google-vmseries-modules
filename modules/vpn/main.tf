
resource "google_compute_ha_vpn_gateway" "ha_gateway" {
  name    = var.vpn_gateway_name
  project = var.project
  region  = var.region
  network = var.network
}

module "vpn_instances" {
  source = "./modules/vpn_instance"

  for_each = var.vpn_config.instances

  project = var.project
  region  = var.region
  network = var.network

  name        = each.value.name
  router_name = "rtr-${each.key}"

  peer_external_gateway = try(each.value.peer_external_gateway, null)
  peer_gcp_gateway      = try(each.value.peer_gcp_gateway, null)

  router_asn = var.vpn_config.router_asn
  tunnels    = each.value.tunnels

  vpn_gateway_self_link   = google_compute_ha_vpn_gateway.ha_gateway.self_link
  router_advertise_config = var.vpn_config.router_advertise_config
}
