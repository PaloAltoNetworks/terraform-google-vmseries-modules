terraform {
  required_version = "~>0.12"
}

provider "google" {
  credentials = file(var.auth_file)
  project     = lower(var.project_id)
  version     = "~> 3.35"
}

#-----------------------------------------------------------------------------------------------
# Create  buckets for bootstrapping the fresh firewall VM.
module "bootstrap" {
  source        = "./modules/gcp_bootstrap"
  bucket_name   = "${var.prefix}-fw-${local.environment}-${local.region}-bootstrap"
  file_location = "./bootstrap_files/${local.region}/${local.environment}/"
  config        = ["init-cfg.txt"]
  license       = ["authcodes"]
  //  content       = ["pancontent","pancontent2"]
  project = var.project_id
}


//#-----------------------------------------------------------------------------------------------
//# Create  firewalls
module "firewalls" {
  source                = "./modules/vmseries"
  region                = local.region
  environment           = local.environment
  prefix                = var.prefix
  tags                  = ["paloalto"]
  subnetworks           = local.subnetwork_map_detail
  machine_type          = var.fw_machine_type
  mgmt_interface_swap   = "enable"
  ssh_key               = fileexists(var.public_key_path) ? "admin:${file(var.public_key_path)}" : ""
  image                 = "${var.fw_image}-${var.fw_panos}"
  create_instance_group = false
  bootstrap_bucket      = module.bootstrap.bucket_name
  firewalls             = var.regions[local.region]["firewalls"]

  dependencies = [
    module.bootstrap.completion,
  ]
}