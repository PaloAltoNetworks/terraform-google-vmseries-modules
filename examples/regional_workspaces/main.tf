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

#-----------------------------------------------------------------------------------------------
# Create  firewalls
module "firewalls" {
  source = "../../modules/vmseries"

  tags                  = ["paloalto"]
  ssh_key               = fileexists(var.public_key_path) ? "admin:${file(var.public_key_path)}" : ""
  image_name            = var.panos_image_name
  create_instance_group = false
  bootstrap_bucket      = module.bootstrap.bucket_name

  instances = { for instance_key, instance in var.regions[local.region]["instances"] :
    instance_key => {
      name = instance.name,
      zone = instance.zone,
      network_interfaces = [for v in instance.network_interfaces :
        {
          subnetwork = module.vpc.subnetworks[v.subnetwork_name].self_link
          public_nat = v.public_nat
          nat_ip     = try(v.nat_ip, null)
          ip_address = try(v.ip_address, null)
        }
      ]
    }
  }

  dependencies = [
    module.bootstrap.completion,
  ]
}
