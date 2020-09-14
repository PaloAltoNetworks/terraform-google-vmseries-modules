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
  project_id      = data.google_project.this.name
  zoning = {
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
  pool                     = google_compute_target_pool.this.self_link
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
  source            = "../../../modules/gcp/lb_tcp_internal/"
  name              = var.intlb_name
  network           = var.trust_vpc
  subnetworks       = var.trust_subnet
  all_ports         = true
  ports             = []
  health_check_port = "22"

  backends = {
    "0" = [
      {
        group    = module.autoscale.instance_group_manager["zone1"].instance_group
        failover = false
      },
      {
        group    = module.autoscale.instance_group_manager["zone2"].instance_group
        failover = false
      }
    ]
  }
}

#-----------------------------------------------------------------------------------------------
# Regional External TCP Network Load Balancer
#
# It is not strictly required part of this example.
# It's here just to show how to integrate it with auto-scaling.

resource "google_compute_forwarding_rule" "this" {
  name                  = var.extlb_name
  target                = google_compute_target_pool.this.self_link
  load_balancing_scheme = "EXTERNAL"
  ip_protocol           = "TCP"
  port_range            = "80"
}

resource "google_compute_target_pool" "this" {
  name             = var.extlb_name
  session_affinity = "NONE" // Options are `NONE`, `CLIENT_IP` and `CLIENT_IP_PROTO`
  health_checks    = [google_compute_http_health_check.this.self_link]
}

resource "google_compute_http_health_check" "this" {
  name = "${var.prefix}-hc"

  check_interval_sec  = 10
  timeout_sec         = 5
  unhealthy_threshold = 3
  healthy_threshold   = 2

  port = var.extlb_healthcheck_port
  # request_path        = var.health_check["request_path"]
  # host                = var.health_check["host"]
}
