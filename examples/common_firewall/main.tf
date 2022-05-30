#-----------------------------------------------------------------------------------------------
# Dedicated IAM service account for running GCP instances of Palo Alto Networks VM-Series.
# Applying this module requires IAM roles Security Admin and Service Account Admin or their equivalents.
# The account will not only be used for running the instances, but also for the GCP plugin access.

module "iam_service_account" {
  source = "../../modules/iam_service_account/"

  service_account_id = var.service_account
}

# Create bucket for bootstrapping the fresh firewall VM.
module "bootstrap" {
  source = "../../modules/bootstrap/"

  service_account = module.iam_service_account.email
  files = {
    "bootstrap_files/init-cfg.txt" = "config/init-cfg.txt"
    "bootstrap_files/authcodes"    = "license/authcodes"
  }
}

module "vpc" {
  source = "../../modules/vpc"

  networks = [
    {
      name            = "${var.name_prefix}fw-untrust"
      subnetwork_name = "${var.name_prefix}fw-untrust"
      ip_cidr_range   = "10.236.64.16/28"
      allowed_sources = var.allowed_sources
    },
    {
      name            = "${var.name_prefix}fw-mgmt"
      subnetwork_name = "${var.name_prefix}fw-mgmt"
      ip_cidr_range   = "10.236.64.0/28"
      allowed_sources = var.allowed_sources
    },
    {
      name            = "${var.name_prefix}fw-trust"
      subnetwork_name = "${var.name_prefix}fw-trust"
      ip_cidr_range   = "10.236.64.32/28"
    },
    {
      name            = "${var.name_prefix}common-vdi"
      subnetwork_name = "${var.name_prefix}common-vdi"
      ip_cidr_range   = "10.236.65.0/24"
      allowed_sources = var.allowed_sources
    },
    {
      name            = "${var.name_prefix}vdi"
      subnetwork_name = "${var.name_prefix}vdi"
      ip_cidr_range   = "10.236.68.0/23"
      allowed_sources = var.allowed_sources
    },
  ]
}

resource "google_compute_network_peering" "from_trust_to_common_vdi" {
  name                 = "${var.name_prefix}trust-to-common-vdi"
  network              = module.vpc.networks["${var.name_prefix}fw-trust"].id
  peer_network         = module.vpc.networks["${var.name_prefix}common-vdi"].id
  export_custom_routes = true
  import_custom_routes = false
}

resource "google_compute_network_peering" "from_common_vdi_to_trust" {
  name                 = "${var.name_prefix}common-vdi-to-trust"
  network              = module.vpc.networks["${var.name_prefix}common-vdi"].id
  peer_network         = module.vpc.networks["${var.name_prefix}fw-trust"].id
  export_custom_routes = false
  import_custom_routes = true
}

resource "google_compute_network_peering" "from_trust_to_vdi" {
  name                 = "${var.name_prefix}inside-to-vdi"
  network              = module.vpc.networks["${var.name_prefix}fw-trust"].id
  peer_network         = module.vpc.networks["${var.name_prefix}vdi"].id
  export_custom_routes = true
  import_custom_routes = false
}

resource "google_compute_network_peering" "from_vdi_to_trust" {
  name                 = "${var.name_prefix}vdi-to-inside"
  network              = module.vpc.networks["${var.name_prefix}vdi"].id
  peer_network         = module.vpc.networks["${var.name_prefix}fw-trust"].id
  export_custom_routes = false
  import_custom_routes = true
}

# Spawn the VM-series firewall as a Google Cloud Engine Instance.
module "vmseries" {
  for_each = var.vmseries
  source   = "../../modules/vmseries"

  name = "${var.name_prefix}${each.key}"
  zone = each.value.zone

  ssh_keys       = var.ssh_keys
  vmseries_image = var.vmseries_common.vmseries_image

  create_instance_group = true

  bootstrap_options = merge({
    vmseries-bootstrap-gce-storagebucket = module.bootstrap.bucket_name
    },
    var.vmseries_common.bootstrap_options,
  )

  network_interfaces = [
    {
      subnetwork      = module.vpc.subnetworks["${var.name_prefix}fw-untrust"].self_link
      private_address = each.value.private_ips["untrust"]
    },
    {
      subnetwork       = module.vpc.subnetworks["${var.name_prefix}fw-mgmt"].self_link
      private_address  = each.value.private_ips["mgmt"]
      create_public_ip = true
    },
    {
      subnetwork      = module.vpc.subnetworks["${var.name_prefix}fw-trust"].self_link
      private_address = each.value.private_ips["trust"]
    },
  ]
}

# Due to intranet load balancer solution - DNAT for healthchecks traffic should be configured on firewall.
# Source: https://knowledgebase.paloaltonetworks.com/KCSArticleDetail?id=kA10g000000PP9QCAW
module "lb_internal" {
  source = "../../modules/lb_internal"

  name       = "${var.name_prefix}fw-ilb"
  backends   = { for k, v in module.vmseries : k => v.instance_group_self_link }
  ip_address = "10.236.64.40"
  subnetwork = module.vpc.subnetworks["${var.name_prefix}fw-trust"].self_link
  network    = "${var.name_prefix}fw-trust"
  all_ports  = true
}

module "lb_external" {
  source = "../../modules/lb_external/"

  instances = [for k, v in module.vmseries : module.vmseries[k].self_link]

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
  router        = "${var.name_prefix}fw-router"
  network       = "${var.name_prefix}fw-mgmt"

  depends_on = [module.vpc]
}
