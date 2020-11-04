terraform {
  required_version = ">= 0.12, < 0.13"
}

provider "google" {
  version = "= 3.35"
}

data "google_compute_zones" "this" {}

#-----------------------------------------------------------------------------------------------
# Dedicated IAM service account for running GCP instances of Palo Alto Networks VM-Series.
# Applying this module requires IAM roles Security Admin and Service Account Admin or their equivalents.
# The account will not only be used for running the instances, but also for their GCP plugin access.

module "iam_service_account" {
  source = "../../modules/iam_service_account/"

  service_account_id = var.service_account
}

# Create  buckets for bootstrapping the fresh firewall VM.
module "bootstrap" {
  source          = "../../modules/gcp_bootstrap/"
  bucket_name     = "as4-fw-bootstrap"
  service_account = module.iam_service_account.email
  file_location   = "bootstrap_files/"
  config          = ["init-cfg.txt"]
  license         = ["authcodes"]
}

#-----------------------------------------------------------------------------------------------
# VPC Networks

module "vpc" {
  source = "../../modules/vpc"

  networks = var.networks
}


#-----------------------------------------------------------------------------------------------
# Firewalls with auto-scaling.

module "autoscale" {
  source = "../../modules/autoscale"

  zones = {
    zone1 = data.google_compute_zones.this.names[0]
    zone2 = data.google_compute_zones.this.names[1]
  }

  subnetworks = [for v in var.fw_network_ordering : module.vpc.subnetworks[v].name]

  prefix                   = var.prefix
  deployment_name          = var.prefix
  machine_type             = var.fw_machine_type
  mgmt_interface_swap      = "enable"
  ssh_key                  = fileexists(var.public_key_path) ? "admin:${file(var.public_key_path)}" : ""
  image                    = "${var.fw_image}-${var.fw_panos}"
  nic0_public_ip           = true
  nic1_public_ip           = true
  nic2_public_ip           = false
  pool                     = module.extlb.target_pool
  bootstrap_bucket         = module.bootstrap.bucket_name
  scopes                   = ["https://www.googleapis.com/auth/cloud-platform"]
  service_account          = module.iam_service_account.email
  max_replicas_per_zone    = 2
  autoscaler_metric_name   = var.autoscaler_metric_name
  autoscaler_metric_type   = var.autoscaler_metric_type
  autoscaler_metric_target = var.autoscaler_metric_target

  dependencies = [
    module.bootstrap.completion,
  ]
}

#-----------------------------------------------------------------------------------------------
# Regional Internal TCP Load Balancer
#
# It is not strictly required part of this example.
# It's here just to show how to integrate it with auto-scaling.

module "intlb" {
  source = "../../modules/lb_tcp_internal/"

  name       = var.intlb_name
  network    = module.vpc.networks[var.intlb_network].name
  subnetwork = module.vpc.subnetworks[var.intlb_network].name
  all_ports  = true
  backends   = module.autoscale.backends
}

#-----------------------------------------------------------------------------------------------
# Regional External TCP Network Load Balancer
#
# It is not strictly required part of this example.
# It's here just to show how to integrate it with auto-scaling.

module "extlb" {
  source = "../../modules/lb_tcp_external/"

  name         = var.extlb_name
  service_port = 80
  health_check = {
    # null means to use a default value
    check_interval_sec  = null
    timeout_sec         = null
    healthy_threshold   = null
    unhealthy_threshold = 3
    port                = 80
    request_path        = "/"
    host                = null
  }
}
