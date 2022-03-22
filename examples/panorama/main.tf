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

  project   = var.project
  region    = var.region
  zone      = data.google_compute_zones.this.names[0]
  subnet    = module.vpc.subnetworks["kbechler-panorama-example"].id
  static_ip = var.static_ip

}

output "panorama_private_ip" { value = module.panorama.nic0_private_ip }
output "panorama_public_ip" { value = module.panorama.nic0_public_ip }



# output "a" { value = data.google_compute_image.this }