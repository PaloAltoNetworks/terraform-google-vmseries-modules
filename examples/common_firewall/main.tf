provider "google" {
  project = var.project
  region  = var.region
}

data "google_compute_zones" "this" {
  region = var.region
}

#-----------------------------------------------------------------------------------------------
# Dedicated IAM service account for running GCP instances of Palo Alto Networks VM-Series.
# Applying this module requires IAM roles Security Admin and Service Account Admin or their equivalents.
# The account will not only be used for running the instances, but also for their GCP plugin access.
# This part should be prepared by Client !

module "iam_service_account" {
  source = "../../modules/iam_service_account/"

  service_account_id = var.service_account
}

# Create  buckets for bootstrapping the fresh firewall VM.
module "bootstrap" {
  source = "../../modules/bootstrap/"

  service_account = module.iam_service_account.email
  files = {
    "bootstrap_files/init-cfg.txt" = "config/init-cfg.txt"
    "bootstrap_files/authcodes"    = "license/authcodes"
    #    "bootstrap_files/vm_series-2.0.2" = "plugins/vm_series-2.0.2"
  }
}

module "vpc" {
  source = "../../modules/vpc"

  networks = [
    {
      name            = "example-fw-untrust"
      subnetwork_name = "example-fw-untrust"
      ip_cidr_range   = "10.236.64.16/28"
      allowed_sources = var.allowed_sources
    },
    {
      name            = "example-fw-mgmt"
      subnetwork_name = "example-fw-mgmt"
      ip_cidr_range   = "10.236.64.0/28"
      allowed_sources = var.allowed_sources
    },
    {
      name            = "example-fw-trust"
      subnetwork_name = "example-fw-trust"
      ip_cidr_range   = "10.236.64.32/28"
    },
    {
      name            = "example-common-vdi"
      subnetwork_name = "example-common-vdi"
      ip_cidr_range   = "10.236.65.0/24"
      allowed_sources = var.allowed_sources
    },
    {
      name            = "example-vdi"
      subnetwork_name = "example-vdi"
      ip_cidr_range   = "10.236.68.0/23"
      allowed_sources = var.allowed_sources
    },
  ]
}

resource "google_compute_network_peering" "from_trust_to_common_vdi" {
  name                 = "from-trust-to-common-vdi"
  network              = module.vpc.networks["example-fw-trust"].id
  peer_network         = module.vpc.networks["example-common-vdi"].id
  export_custom_routes = true
  import_custom_routes = false
}

resource "google_compute_network_peering" "from_common_vdi_to_trust" {
  name                 = "from-common-vdi-to-trust"
  network              = module.vpc.networks["example-common-vdi"].id
  peer_network         = module.vpc.networks["example-fw-trust"].id
  export_custom_routes = false
  import_custom_routes = true
}

resource "google_compute_network_peering" "from_trust_to_vdi" {
  name                 = "from-inside-to-vdi"
  network              = module.vpc.networks["example-fw-trust"].id
  peer_network         = module.vpc.networks["example-vdi"].id
  export_custom_routes = true
  import_custom_routes = false
}

resource "google_compute_network_peering" "from_vdi_to_trust" {
  name                 = "from-vdi-to-inside"
  network              = module.vpc.networks["example-vdi"].id
  peer_network         = module.vpc.networks["example-fw-trust"].id
  export_custom_routes = false
  import_custom_routes = true
}

# Spawn the VM-series firewall as a Google Cloud Engine Instance.
module "vmseries" {
  source                = "../../modules/vmseries"
  create_instance_group = true
  bootstrap_bucket      = module.bootstrap.bucket_name

  instances = {
    "example-fw-fw01" = {
      name = "example-fw-fw01"
      zone = data.google_compute_zones.this.names[2]
      network_interfaces = [
        {
          subnetwork = module.vpc.subnetworks["example-fw-untrust"].self_link
          public_nat = false
          ip_address = "10.236.64.20"
        },
        {
          subnetwork = module.vpc.subnetworks["example-fw-mgmt"].self_link
          ip_address = "10.236.64.2"
          public_nat = false
        },
        {
          subnetwork = module.vpc.subnetworks["example-fw-trust"].self_link
          public_nat = false
          ip_address = "10.236.64.35"
        },
      ]
    }
    "example-fw-fw02" = {
      name = "example-fw-fw02"
      zone = data.google_compute_zones.this.names[1]
      network_interfaces = [
        {
          subnetwork = module.vpc.subnetworks["example-fw-untrust"].self_link
          public_nat = false
          ip_address = "10.236.64.21"
        },
        {
          subnetwork = module.vpc.subnetworks["example-fw-mgmt"].self_link
          ip_address = "10.236.64.3"
          public_nat = false
        },
        {
          subnetwork = module.vpc.subnetworks["example-fw-trust"].self_link
          public_nat = false
          ip_address = "10.236.64.36"
        },
      ]
    }
  }

  ssh_key   = var.ssh_key
  image_uri = var.image_uri
}

# Due to intranet load balancer solution - DNAT for healthchecks traffic should be configured on firewall.
# Source: https://knowledgebase.paloaltonetworks.com/KCSArticleDetail?id=kA10g000000PP9QCAW

module "lb_tcp_internal" {
  source = "../../modules/lb_tcp_internal"

  name       = "example-fw-ilb"
  backends   = module.vmseries.instance_group_self_links
  ip_address = "10.236.64.40"
  subnetwork = module.vpc.subnetworks["example-fw-trust"].self_link
  network    = "example-fw-trust"
  all_ports  = true
}

module "lb_tcp_external" {
  source = "../../modules/lb_tcp_external/"

  instances = [for k, v in module.vmseries.instances : module.vmseries.instances[k].self_link]

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

  name          = "cloud-mgmnt-nat"
  project_id    = var.project
  region        = var.region
  create_router = true
  router        = "example-fw-router"
  network       = "example-fw-mgmt"

  depends_on = [module.vpc]
}

output "self_link" {
  value = { for k, v in module.vmseries.self_links : k => v }
}

output "ssh_command" {
  value = { for k, v in module.vmseries.nic1_ips : k => "ssh admin@${v}" }
}
