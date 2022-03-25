provider "google" {
  project = var.project
  region  = var.region
}

data "google_compute_zones" "this" {
  region = var.region
}

module "vpc" {
  source = "../../modules/vpc"

  networks = [
    {
      name            = var.vpc_name
      subnetwork_name = var.subnet_name
      ip_cidr_range   = var.cidr
      allowed_sources = var.allowed_sources
    }
  ]
}

module "panorama" {
  source = "../../modules/panorama"

  project           = var.project
  region            = var.region
  zone              = data.google_compute_zones.this.names[0]
  panorama_version  = var.panorama_version
  ssh_keys          = var.ssh_keys
  subnet            = module.vpc.subnetworks["panorama-example-subnet"].id
  private_static_ip = var.private_static_ip
  attach_public_ip  = var.attach_public_ip
}
