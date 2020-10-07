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
  bucket_name   = "${var.prefix}-fw-${local.environment}-${local.region}-bootstrap"
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
    # FIXME move this code to "vpc"
    for k, v in var.regions[local.region]["instances"] : k => merge(v,
      { network_interfaces = module.vpc.nicspec }
    )
  }
}

//#-----------------------------------------------------------------------------------------------
//# Create  firewalls
module "firewalls" {
  source = "../../modules/vmseries"
  // FIXME region                = local.region
  // FIXME subnetworks           = local.subnetwork_map_detail
  // FIXME environment           = local.environment
  tags                  = ["paloalto"]
  ssh_key               = fileexists(var.public_key_path) ? "admin:${file(var.public_key_path)}" : ""
  image_name            = var.panos_image_name
  create_instance_group = false
  bootstrap_bucket      = module.bootstrap.bucket_name
  instances             = local.instances

  dependencies = [
    module.bootstrap.completion,
  ]
}
