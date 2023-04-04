data "google_compute_zones" "this" {
  region = var.region
}

module "vpc" {
  source = "../../modules/vpc"

  networks = { for k, v in var.networks : k => merge(v, {
    name            = "${var.name_prefix}${v.name}"
    subnetwork_name = "${var.name_prefix}${v.subnetwork_name}"
    })
  }
}

module "panorama" {
  source = "../../modules/panorama"

  for_each = var.panoramas

  name              = "${var.name_prefix}${each.value.panorama_name}"
  project           = var.project
  region            = var.region
  zone              = data.google_compute_zones.this.names[0]
  panorama_version  = each.value.panorama_version
  ssh_keys          = each.value.ssh_keys
  subnet            = module.vpc.subnetworks["${var.name_prefix}${each.value.panorama_subnet}"].self_link
  private_static_ip = each.value.private_static_ip
  attach_public_ip  = each.value.attach_public_ip
  log_disks         = each.value.log_disks
  depends_on        = [module.vpc]
}