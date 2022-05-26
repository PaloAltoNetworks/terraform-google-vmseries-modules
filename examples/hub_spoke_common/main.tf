# ----------------------------------------------------------------------------------------------------------------
# Setup providers, pull availability zones, and create name prefix.

data "google_client_config" "main" {
}

data "google_compute_zones" "main" {
  project = data.google_client_config.main.project
  region  = var.region
}

resource "random_string" "main" {
  length    = 5
  min_lower = 5
  special   = false
}

locals {
  prefix = var.prefix != null && var.prefix != "" ? "${var.prefix}-" : ""

  vmseries = {
    fw01 = {
      name = "vmseries01"
      zone = data.google_compute_zones.main.names[0]
    }
    fw02 = {
      name = "vmseries02"
      zone = data.google_compute_zones.main.names[1]
    }
  }
}


# ----------------------------------------------------------------------------------------------------------------
# Create mgmt, untrust, and trust networks

module "vpc_mgmt" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 4.0"
  project_id   = var.project_id
  network_name = "${local.prefix}mgmt-vpc"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name   = "${local.prefix}${var.region}-mgmt"
      subnet_ip     = var.cidr_mgmt
      subnet_region = var.region
    }
  ]

  firewall_rules = [
    {
      name        = "${local.prefix}vmseries-mgmt"
      direction   = "INGRESS"
      priority    = "100"
      description = "Allow ingress access to VM-Series management interface"
      ranges      = var.allowed_sources
      allow = [
        {
          protocol = "tcp"
          ports    = ["22", "443"]
        }
      ]
    }
  ]
}

module "vpc_untrust" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 4.0"
  project_id   = var.project_id
  network_name = "${local.prefix}untrust-vpc"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name   = "${local.prefix}${var.region}-untrust"
      subnet_ip     = var.cidr_untrust
      subnet_region = var.region
    }
  ]

  firewall_rules = [
    {
      name      = "${local.prefix}allow-all-untrust"
      direction = "INGRESS"
      priority  = "100"
      ranges    = ["0.0.0.0/0"]
      allow = [
        {
          protocol = "all"
          ports    = []
        }
      ]
    }
  ]
}

module "vpc_trust" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "~> 4.0"
  project_id                             = var.project_id
  network_name                           = "${local.prefix}trust-vpc"
  routing_mode                           = "GLOBAL"
  delete_default_internet_gateway_routes = true

  subnets = [
    {
      subnet_name   = "${local.prefix}${var.region}-trust"
      subnet_ip     = var.cidr_trust
      subnet_region = var.region
    }
  ]

  firewall_rules = [
    {
      name      = "${local.prefix}allow-all-trust"
      direction = "INGRESS"
      priority  = "100"
      ranges    = ["0.0.0.0/0"]
      allow = [
        {
          protocol = "all"
          ports    = []
        }
      ]
    }
  ]
}


# ----------------------------------------------------------------------------------------------------------------
# Create VM-Series

# Create IAM service account for accessing bootstrap bucket
module "iam_service_account" {
  source = "../../modules/iam_service_account/"

  service_account_id = "${local.prefix}panw-sa"
}

# Create storage bucket to bootstrap VM-Series.
module "bootstrap" {
  source = "../../modules/bootstrap/"

  service_account = module.iam_service_account.email
  files = {
    "bootstrap_files/init-cfg.txt"  = "config/init-cfg.txt"
    "bootstrap_files/bootstrap.xml" = "config/bootstrap.xml"
  }
}

# Create 2 VM-Series firewalls
module "vmseries" {
  for_each = local.vmseries
  source   = "../../modules/vmseries"

  name                  = "${local.prefix}${each.key}"
  zone                  = each.value.zone
  ssh_keys              = fileexists(var.public_key_path) ? "admin:${file(var.public_key_path)}" : ""
  vmseries_image        = var.fw_image_name
  create_instance_group = true

  metadata = {
    mgmt-interface-swap                  = "enable"
    vmseries-bootstrap-gce-storagebucket = module.bootstrap.bucket_name
    serial-port-enable                   = true
  }

  network_interfaces = [
    {
      subnetwork       = module.vpc_untrust.subnets_self_links[0]
      create_public_ip = false
    },
    {
      subnetwork       = module.vpc_mgmt.subnets_self_links[0]
      create_public_ip = true
    },
    {
      subnetwork = module.vpc_trust.subnets_self_links[0]
    }
  ]
}


# ----------------------------------------------------------------------------------------------------------------
# Create internal and external load balancer to distribute traffic to VM-Series

module "lb_tcp_internal" {
  source = "../../modules/lb_tcp_internal"

  name       = "${local.prefix}fw-ilb"
  backends   = { for k, v in module.vmseries : k => v.instance_group_self_link }
  ip_address = cidrhost(var.cidr_trust, 10)
  subnetwork = module.vpc_trust.subnets_self_links[0]
  network    = module.vpc_trust.network_id
  all_ports  = true
}

module "lb_tcp_external" {
  source = "../../modules/lb_tcp_external/"

  instances = [for k, v in module.vmseries : module.vmseries[k].self_link]
  name      = "${local.prefix}fw-extlb"
  rules = {
    "rule1" = { port_range = 80 },
    "rule2" = { port_range = 22 }
  }

  health_check_http_port         = 80
  health_check_http_request_path = "/"
}