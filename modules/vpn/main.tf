

resource "google_compute_ha_vpn_gateway" "ha_gateway" {
  name    = var.vpn_gateway_name
  project = var.project
  region  = var.region
  network = var.vpc_network_id
}

module "vpn_ha" {
  source  = "terraform-google-modules/vpn/google//modules/vpn_ha"
  version = "3.0.1"

  for_each = var.vpn_config.instances

  project_id = var.project
  region     = var.region
  network    = var.vpc_network_id

  name = each.value.name

  peer_external_gateway = try(each.value.peer_external_gateway, null)
  peer_gcp_gateway      = try(each.value.peer_gcp_gateway, null)

  router_asn = var.vpn_config.router_asn
  tunnels    = each.value.tunnels

  create_vpn_gateway      = false
  vpn_gateway_self_link   = google_compute_ha_vpn_gateway.ha_gateway.self_link
  router_advertise_config = var.vpn_config.router_advertise_config
}