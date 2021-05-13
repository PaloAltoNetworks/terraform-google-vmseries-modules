terraform {
  required_version = ">= 0.12, < 0.13"
}

provider "google" {
  version = "= 3.48"
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
  source = "../../modules/bootstrap/"

  service_account = module.iam_service_account.email
  files = {
    "bootstrap_files/init-cfg.txt"    = "config/init-cfg.txt"
    "bootstrap_files/authcodes"       = "license/authcodes"
    "bootstrap_files/vm_series-2.0.2" = "plugins/vm_series-2.0.2"
  }
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

  prefix                = var.prefix
  deployment_name       = var.prefix
  machine_type          = var.fw_machine_type
  mgmt_interface_swap   = "enable"
  ssh_key               = fileexists(var.public_key_path) ? "admin:${file(var.public_key_path)}" : ""
  image                 = var.fw_image_uri
  nic0_public_ip        = true
  nic1_public_ip        = false
  nic2_public_ip        = false
  pool                  = module.extlb.target_pool
  bootstrap_bucket      = module.bootstrap.bucket_name
  scopes                = ["https://www.googleapis.com/auth/cloud-platform"]
  service_account       = module.iam_service_account.email
  max_replicas_per_zone = 2
  autoscaler_metrics    = var.autoscaler_metrics
  named_ports = [
    {
      name = "http"
      port = "80"
    },
  ]

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

  allow_global_access = var.intlb_global_access
}

#-----------------------------------------------------------------------------------------------
# Regional External TCP Network Load Balancer
#
# It is not strictly required part of this example.
# It's here just to show how to integrate it with auto-scaling.

module "extlb" {
  source = "../../modules/lb_tcp_external/"

  name  = var.extlb_name
  rules = { (var.extlb_name) = { port_range = 80 } }

  health_check_http_port         = 80
  health_check_http_request_path = "/"
}

# -----------------------------------------------------------------------------------------------
# Cloud Nat for the management interfaces.
# Needed to reach bootstrap bucket or to log to Cortex DataLake.
module "mgmt_cloud_nat" {
  source  = "terraform-google-modules/cloud-nat/google"
  version = "=1.2"

  name          = "mgmt"
  project_id    = "gcp-gcs-pso" # FIXME vars? other module?
  region        = "europe-west4"
  create_router = true
  router        = "mgmt"
  network       = var.mgmt_network
}
