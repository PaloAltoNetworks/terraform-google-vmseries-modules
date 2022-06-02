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

module "vpc_region0" {
  source = "../../modules/vpc"

  networks = [
    {
      name            = "${var.name_prefix}fw-untrust"
      subnetwork_name = "${var.name_prefix}fw-untrust-${var.region0}"
      ip_cidr_range   = "10.236.64.16/28"
      allowed_sources = var.allowed_sources
      region          = var.region0
    },
    {
      name            = "${var.name_prefix}fw-mgmt"
      subnetwork_name = "${var.name_prefix}fw-mgmt-${var.region0}"
      ip_cidr_range   = "10.236.64.0/28"
      allowed_sources = var.allowed_sources
      region          = var.region0
    },
    {
      name                            = "${var.name_prefix}fw-trust"
      subnetwork_name                 = "${var.name_prefix}fw-trust-${var.region0}"
      ip_cidr_range                   = "10.236.64.32/28"
      region                          = var.region0
      delete_default_routes_on_create = true
    },
  ]
}

module "vpc_region1" {
  source = "../../modules/vpc"

  networks = [
    {
      name            = "${var.name_prefix}fw-untrust"
      subnetwork_name = "${var.name_prefix}fw-untrust-${var.region1}"
      ip_cidr_range   = "10.236.65.16/28"
      allowed_sources = var.allowed_sources
      create_network  = false
      region          = var.region1
    },
    {
      name            = "${var.name_prefix}fw-mgmt"
      subnetwork_name = "${var.name_prefix}fw-mgmt-${var.region1}"
      ip_cidr_range   = "10.236.65.0/28"
      allowed_sources = var.allowed_sources
      create_network  = false
      region          = var.region1
    },
    {
      name            = "${var.name_prefix}fw-trust"
      subnetwork_name = "${var.name_prefix}fw-trust-${var.region1}"
      ip_cidr_range   = "10.236.65.32/28"
      create_network  = false
      region          = var.region1
    },
  ]
  depends_on = [module.vpc_region0]
}

# Spawn the VM-series firewall as a Google Cloud Engine Instance.
module "vmseries_region0" {
  for_each = var.vmseries_region0
  source   = "../../modules/vmseries"

  name = "${var.name_prefix}${each.value.name}"
  zone = each.value.zone

  ssh_keys       = var.ssh_keys
  vmseries_image = var.vmseries_common.vmseries_image

  create_instance_group = true
  service_account       = module.iam_service_account.email

  bootstrap_options = merge({
    vmseries-bootstrap-gce-storagebucket = module.bootstrap.bucket_name
    },
    var.vmseries_common.bootstrap_options,
  )

  network_interfaces = [
    {
      subnetwork      = module.vpc_region0.subnetworks["${var.name_prefix}fw-untrust-${each.value.region}"].self_link
      private_address = each.value.private_ips["untrust"]
    },
    {
      subnetwork       = module.vpc_region0.subnetworks["${var.name_prefix}fw-mgmt-${each.value.region}"].self_link
      private_address  = each.value.private_ips["mgmt"]
      create_public_ip = true
    },
    {
      subnetwork      = module.vpc_region0.subnetworks["${var.name_prefix}fw-trust-${each.value.region}"].self_link
      private_address = each.value.private_ips["trust"]
    },
  ]
}

module "vmseries_region1" {
  for_each = var.vmseries_region1
  source   = "../../modules/vmseries"

  name = "${var.name_prefix}${each.value.name}"
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
      subnetwork      = module.vpc_region1.subnetworks["${var.name_prefix}fw-untrust-${each.value.region}"].self_link
      private_address = each.value.private_ips["untrust"]
    },
    {
      subnetwork       = module.vpc_region1.subnetworks["${var.name_prefix}fw-mgmt-${each.value.region}"].self_link
      private_address  = each.value.private_ips["mgmt"]
      create_public_ip = true
    },
    {
      subnetwork      = module.vpc_region1.subnetworks["${var.name_prefix}fw-trust-${each.value.region}"].self_link
      private_address = each.value.private_ips["trust"]
    },
  ]
}

## Due to intranet load balancer solution - DNAT for healthchecks traffic should be configured on firewall.
## Source: https://knowledgebase.paloaltonetworks.com/KCSArticleDetail?id=kA10g000000PP9QCAW
module "lb_tcp_internal_region0" {
  source = "../../modules/lb_internal"

  name                = "${var.name_prefix}fw-ilb-${var.region0}"
  region              = var.region0
  backends            = { for k, v in module.vmseries_region0 : k => v.instance_group_self_link }
  ip_address          = "10.236.64.40"
  subnetwork          = module.vpc_region0.subnetworks["${var.name_prefix}fw-trust-${var.region0}"].self_link
  network             = "${var.name_prefix}fw-trust"
  all_ports           = true
  allow_global_access = var.allow_global_access
}

module "lb_tcp_internal_region1" {
  source = "../../modules/lb_internal"

  name                = "${var.name_prefix}fw-ilb-${var.region1}"
  region              = var.region1
  backends            = { for k, v in module.vmseries_region1 : k => v.instance_group_self_link }
  ip_address          = "10.236.65.40"
  subnetwork          = module.vpc_region1.subnetworks["${var.name_prefix}fw-trust-${var.region1}"].self_link
  network             = "${var.name_prefix}fw-trust"
  all_ports           = true
  allow_global_access = var.allow_global_access
}

resource "google_compute_route" "region0" {
  name         = "${var.name_prefix}fw-route-${var.region0}"
  dest_range   = "0.0.0.0/0"
  network      = "${var.name_prefix}fw-trust"
  next_hop_ilb = module.lb_tcp_internal_region0.forwarding_rule
  priority     = 1000
  tags         = [var.region0]
}

resource "google_compute_route" "region1" {
  name         = "${var.name_prefix}fw-route-${var.region1}"
  dest_range   = "0.0.0.0/0"
  network      = "${var.name_prefix}fw-trust"
  next_hop_ilb = module.lb_tcp_internal_region1.forwarding_rule
  priority     = 1000
  tags         = [var.region1]
}
