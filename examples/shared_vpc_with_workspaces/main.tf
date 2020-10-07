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
  instances             = var.regions[local.region]["instances"]

  dependencies = [
    module.bootstrap.completion,
  ]
}
