terraform {
  required_version = ">= 0.12, < 0.13"
}

provider "google" {
  version = "= 3.35"
}

data "google_project" "this" {}
data "google_compute_zones" "this" {}

#-----------------------------------------------------------------------------------------------
# Create  buckets for bootstrapping the fresh firewall VM.

module "bootstrap" {
  source          = "../../../modules/gcp/gcp_bootstrap/"
  bucket_name     = "as4-fw-bootstrap"
  service_account = var.service_account
  file_location   = "bootstrap_files/"
  config          = ["init-cfg.txt"]
  license         = ["authcodes"]
}

#-----------------------------------------------------------------------------------------------
# Firewalls with auto-scaling.

module "autoscale" {
  source          = "../../../modules/gcp/autoscale"
  prefix          = var.prefix
  deployment_name = var.prefix

  zones = {
    zone1 = data.google_compute_zones.this.names[0]
    zone2 = data.google_compute_zones.this.names[1]
  }

  subnetworks = [
    var.untrust_subnet[0],
    var.mgmt_subnet[0],
    var.trust_subnet[0],
  ]

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
  service_account          = var.service_account
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
  source     = "../../../modules/gcp/lb_tcp_internal/"
  name       = var.intlb_name
  network    = var.trust_vpc
  subnetwork = var.trust_subnet[0]
  all_ports  = true
  backends   = module.autoscale.backends
}

#-----------------------------------------------------------------------------------------------
# Regional External TCP Network Load Balancer
#
# It is not strictly required part of this example.
# It's here just to show how to integrate it with auto-scaling.

module "extlb" {
  source       = "../../../modules/gcp/lb_tcp_external/"
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
