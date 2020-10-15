terraform {
  required_version = "~>0.12"
}

provider "google" {
  credentials = file(var.auth_file)
  project     = lower(var.project_id)
  version     = "= 3.35"
}

#-----------------------------------------------------------------------------------------------
# Create  buckets for bootstrapping the fresh firewall VM.
module "bootstrap" {
  source        = "../../modules/gcp_bootstrap"
  bucket_name   = "${var.prefix}fw-bootstrap-${local.environment}-${local.region}"
  file_location = "./bootstrap_files/${local.region}/${local.environment}/"
  config        = ["init-cfg.txt"]
  license       = ["authcodes"]
  //  content       = ["pancontent","pancontent2"]
}

#-----------------------------------------------------------------------------------------------
# Create subnetworks on our brownfield.
# Or just gather subnetworks' data if they already exist on the brownfield.
module "vpc" {
  source   = "../../modules/vpc"
  networks = var.regions[local.region].networks
  region   = local.region
}

locals {
  instances = {
    for k, v in var.regions[local.region]["instances"] : k => {
      name                      = "${var.prefix}-${local.environment}-${local.region}-${v.name}"
      zone                      = v.zone
      network_interfaces_base   = try(v.network_interfaces_base, [])
      network_interfaces        = module.vpc.nicspec
      network_interfaces_custom = try(v.network_interfaces_custom, [])
    }
  }
}

//#-----------------------------------------------------------------------------------------------
//# Reserve the dynamic addresses
module "vmseries_addresses" {
  source = "../../modules/vmseries_addresses"

  instances = local.instances
}

//#-----------------------------------------------------------------------------------------------
//# Create  firewalls
module "firewalls" {
  source = "../../modules/vmseries"

  tags                  = ["paloalto"]
  ssh_key               = fileexists(var.public_key_path) ? "admin:${file(var.public_key_path)}" : ""
  image_name            = var.panos_image_name
  create_instance_group = false
  bootstrap_bucket      = module.bootstrap.bucket_name
  instances             = module.vmseries_addresses.instances

  dependencies = [
    module.bootstrap.completion,
  ]
}
