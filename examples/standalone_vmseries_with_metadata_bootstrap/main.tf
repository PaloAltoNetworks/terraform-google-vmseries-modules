module "management_vpc" {
  source = "../../modules/vpc"

  networks = [
    {
      name            = "example-mgmt"
      subnetwork_name = "example-mgmt"
      ip_cidr_range   = "10.236.64.0/28"
      allowed_sources = var.allowed_sources
    }
  ]
}

module "vmseries" {
  source = "../../modules/vmseries"

  name = "example-vmseries"
  zone = "us-central1-a"

  ssh_keys       = var.ssh_keys
  vmseries_image = var.vmseries_image

  bootstrap_options = var.bootstrap_options

  network_interfaces = [
    {
      subnetwork       = module.management_vpc.subnetworks["example-mgmt"].self_link
      create_public_ip = true
    },
  ]
}