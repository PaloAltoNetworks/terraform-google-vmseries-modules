data "google_compute_network" "test" {
  name    = var.network_name
  project = var.project
}

module "vpn" {
  source = "../../../modules/vpn"

  project = var.project
  region  = var.region

  vpn_gateway_name = var.vpn_gateway_name
  router_name      = var.router_name
  network          = data.google_compute_network.test.self_link

  vpn_config = var.vpn_config
}