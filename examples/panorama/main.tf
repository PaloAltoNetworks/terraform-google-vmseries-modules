data "google_compute_zones" "this" {
  region = var.region
}

module "vpc" {
  source  = "PaloAltoNetworks/vmseries-modules/google//modules/vpc"
  version = "0.5.1"

  for_each = var.vpcs

  networks = [
    {
      name              = each.value.vpc_name
      subnetwork_name   = each.value.subnet_name
      ip_cidr_range     = each.value.cidr
      allowed_sources   = try(each.value.allowed_sources, [])
      create_network    = each.value.create_network
      create_subnetwork = each.value.create_subnetwork
      region            = var.region
    }
  ]
}

module "panorama" {
  source  = "PaloAltoNetworks/vmseries-modules/google//modules/panorama"
  version = "0.5.1"

  for_each = var.panoramas

  name              = each.value.panorama_name
  project           = var.project
  region            = var.region
  zone              = data.google_compute_zones.this.names[0]
  panorama_version  = each.value.panorama_version
  ssh_keys          = each.value.ssh_keys
  subnet            = each.value.panorama_subnet
  private_static_ip = each.value.private_static_ip
  attach_public_ip  = each.value.attach_public_ip
  log_disks         = each.value.log_disks
}