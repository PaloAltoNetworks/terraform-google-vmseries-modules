
data "google_client_config" "main" {
}

data "google_compute_zones" "main" {
  project = data.google_client_config.main.project
  region  = var.region
}

locals {
  prefix = var.prefix != null && var.prefix != "" ? "${var.prefix}-" : ""

  vmseries_vms = {
    vmseries01 = {
      zone                      = data.google_compute_zones.main.names[0]
      management_private_ip     = "192.168.0.2"
      managementpeer_private_ip = "192.168.0.3"
      untrust_private_ip        = "192.168.1.2"
      untrust_gateway_ip        = "192.168.1.1"
      trust_private_ip          = "192.168.2.2"
      trust_gateway_ip          = "192.168.2.1"
      ha2_private_ip            = "192.168.3.2"
      ha2_subnet_mask           = "255.255.255.0"
      ha2_gateway_ip            = "192.168.3.1"
      external_lb_ip            = google_compute_address.external_nat_ip.address
    }
    vmseries02 = {
      zone                      = data.google_compute_zones.main.names[1]
      management_private_ip     = "192.168.0.3"
      managementpeer_private_ip = "192.168.0.2"
      untrust_private_ip        = "192.168.1.3"
      untrust_gateway_ip        = "192.168.1.1"
      trust_private_ip          = "192.168.2.3"
      trust_gateway_ip          = "192.168.2.1"
      ha2_private_ip            = "192.168.3.3"
      ha2_subnet_mask           = "255.255.255.0"
      ha2_gateway_ip            = "192.168.3.1"
      external_lb_ip            = google_compute_address.external_nat_ip.address
    }
  }
}

data "template_file" "bootstrap_xml" {
  for_each = local.vmseries_vms

  template = file("bootstrap_files/bootstrap.xml.template")
  vars = {
    external_lb_ip            = google_compute_address.external_nat_ip.address
    management_private_ip     = each.value.management_private_ip
    managementpeer_private_ip = each.value.managementpeer_private_ip
    untrust_private_ip        = each.value.untrust_private_ip
    untrust_gateway_ip        = each.value.untrust_gateway_ip
    trust_private_ip          = each.value.trust_private_ip
    trust_gateway_ip          = each.value.trust_gateway_ip
    ha2_private_ip            = each.value.ha2_private_ip
    ha2_subnet_mask           = each.value.ha2_subnet_mask
    ha2_gateway_ip            = each.value.ha2_gateway_ip
  }
}

resource "local_file" "bootstrap_xml" {
  for_each = local.vmseries_vms

  filename = "tmp/bootstrap-${each.key}"
  content  = data.template_file.bootstrap_xml[each.key].rendered
}

# Create IAM service account for accessing bootstrap bucket
module "iam_service_account" {
  source = "../../modules/iam_service_account/"

  service_account_id = "${local.prefix}vmseries-sa"
}

# Create storage bucket to bootstrap VM-Series.
module "bootstrap" {
  for_each = local.vmseries_vms

  source = "../../modules/bootstrap/"

  name_prefix     = local.prefix
  service_account = module.iam_service_account.email
  files = {
    "bootstrap_files/init-cfg.txt.sample" = "config/init-cfg.txt"
    "tmp/bootstrap-${each.key}"           = "config/bootstrap.xml"
  }

  depends_on = [
    local_file.bootstrap_xml
  ]
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
    },
    {
      name        = "${local.prefix}vmseries-ha1"
      direction   = "INGRESS"
      priority    = "100"
      description = "Allow ingress access to VM-Series management interface"
      ranges      = [var.cidr_mgmt]
      allow = [
        {
          protocol = "TCP"
          ports    = []
        },
        {
          protocol = "icmp"
          ports    = []
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


module "vpc_ha2" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "~> 4.0"
  project_id                             = var.project_id
  network_name                           = "${local.prefix}ha2-vpc"
  routing_mode                           = "GLOBAL"
  delete_default_internet_gateway_routes = true

  subnets = [
    {
      subnet_name   = "${local.prefix}${var.region}-ha2"
      subnet_ip     = var.cidr_ha2
      subnet_region = var.region
    }
  ]

  firewall_rules = [
    {
      name      = "${local.prefix}allow-all-ha2"
      direction = "INGRESS"
      priority  = "100"
      ranges    = [var.cidr_ha2]
      allow = [
        {
          protocol = "all"
          ports    = []
        }
      ]
    }
  ]
}

# create the 2 vm-series instances
module "vmseries" {
  for_each = local.vmseries_vms
  source   = "../../modules/vmseries"

  name                  = "${local.prefix}${each.key}"
  zone                  = each.value.zone
  ssh_keys              = fileexists(var.public_key_path) ? "admin:${file(var.public_key_path)}" : ""
  vmseries_image        = var.fw_image_name
  create_instance_group = true

  service_account = module.iam_service_account.email

  metadata = {
    mgmt-interface-swap                  = "enable"
    vmseries-bootstrap-gce-storagebucket = module.bootstrap[each.key].bucket_name
    serial-port-enable                   = true
  }

  network_interfaces = [
    {
      subnetwork = module.vpc_untrust.subnets_self_links[0]
      private_ip = each.value.untrust_private_ip
    },
    {
      subnetwork       = module.vpc_mgmt.subnets_self_links[0]
      create_public_ip = true
      private_ip       = each.value.management_private_ip
    },
    {
      subnetwork = module.vpc_trust.subnets_self_links[0]
      private_ip = each.value.trust_private_ip
    },
    {
      subnetwork = module.vpc_ha2.subnets_self_links[0]
      private_ip = each.value.ha2_private_ip
    },
  ]

  depends_on = [
    module.bootstrap
  ]
}


# ----------------------------------------------------------------------------------------------------------------
# Create internal and external load balancer to distribute traffic to VM-Series

# Due to intranet load balancer solution - DNAT for healthchecks traffic should be configured on firewall.
# Source: https://knowledgebase.paloaltonetworks.com/KCSArticleDetail?id=kA10g000000PP9QCAW
module "lb_internal" {
  source = "../../modules/lb_internal/"

  name                = "${local.prefix}fw-int-lb"
  backends            = { for k, v in module.vmseries : k => v.instance_group_self_link }
  ip_address          = cidrhost(var.cidr_trust, 10)
  subnetwork          = module.vpc_trust.subnets_self_links[0]
  network             = module.vpc_trust.network_id
  all_ports           = true
  health_check_port   = 80
  timeout_sec         = 1
  check_interval_sec  = 1
  healthy_threshold   = 1
  unhealthy_threshold = 1

  connection_idle_timeout_sec                  = 600
  connection_persistence_on_unhealthy_backends = "NEVER_PERSIST"
  connection_tracking_mode                     = "PER_SESSION"
}

# NAT IP for Outbound Services
resource "google_compute_address" "external_nat_ip" {
  name   = "${local.prefix}fw-ext-lb"
  address_type = "EXTERNAL"
}

module "lb_external" {
  source = "../../modules/lb_external/"

  name                    = "${local.prefix}fw-ext-lb"
  project                 = var.project_id
  region                  = var.region
  backend_instance_groups = [for k, v in module.vmseries : module.vmseries[k].instance_group_self_link]
  rules = {
    "rule1" = {
      all_ports                = true
      protocol                 = "UNSPECIFIED"
      ip_protocol              = "L3_DEFAULT"
      connection_tracking_mode = "PER_SESSION"
      ip_address               = google_compute_address.external_nat_ip.address
    }
  }
  health_check_http_port                       = 80
  health_check_http_request_path               = "/php/login.php"
  connection_persistence_on_unhealthy_backends = "NEVER_PERSIST"
  health_check_healthy_threshold               = 1
  health_check_interval_sec                    = 1
  health_check_timeout_sec                     = 1

  depends_on = [
    google_compute_address.external_nat_ip
  ]
}

module "vpc_workload" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "~> 4.0"
  project_id                             = var.project_id
  network_name                           = "${local.prefix}workload-vpc"
  routing_mode                           = "GLOBAL"
  delete_default_internet_gateway_routes = true

  subnets = [
    {
      subnet_name   = "${local.prefix}${var.region}-workload"
      subnet_ip     = var.cidr_workload
      subnet_region = var.region
    }
  ]

  routes = [
    {
      name              = "${local.prefix}workload-to-int-lb"
      description       = "Default route to VM-Series NGFW LB"
      destination_range = "0.0.0.0/0"
      next_hop_ilb      = module.lb_internal.address
    }
  ]

  firewall_rules = [
    {
      name      = "${local.prefix}allow-all-workload"
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


resource "google_compute_network_peering" "trust_to_workload" {
  name         = "trust-to-workload"
  network      = module.vpc_trust.network_self_link
  peer_network = module.vpc_workload.network_self_link
}

resource "google_compute_network_peering" "workload_to_trust" {
  name         = "workload-to-trust"
  network      = module.vpc_workload.network_self_link
  peer_network = module.vpc_trust.network_self_link
}

resource "google_compute_instance" "workload_vm" {
  name         = "workload-vm"
  project      = var.project_id
  machine_type = "n2-standard-2"
  zone         = data.google_compute_zones.main.names[0]

  metadata_startup_script = <<SCRIPT

    echo "while :" >> /network-check.sh
    echo "do" >> /network-check.sh
    echo "  timeout -k 2 2 ping -c 1  8.8.8.8 >> /dev/null" >> /network-check.sh
    echo "  if [ $? -eq 0 ]; then" >> /network-check.sh
    echo "    echo \$(date) -- Online -- Source IP = \$(curl https://checkip.amazonaws.com -s --connect-timeout 1)" >> /network-check.sh
    echo "  else" >> /network-check.sh
    echo "    echo \$(date) -- Offline" >> /network-check.sh
    echo "  fi" >> /network-check.sh
    echo "  sleep 1" >> /network-check.sh
    echo "done" >> /network-check.sh
    chmod +x /network-check.sh

    while ! ping -q -c 1 -W 1 google.com >/dev/null
    do
      echo "waiting for internet connection..."
      sleep 10s
    done
    echo "internet connection available!"

    apt update && apt install -y apache2

    SCRIPT

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    subnetwork = module.vpc_workload.subnets_ids[0]
  }

  # Apply the firewall rule to allow external IPs to ping this instance
  tags = ["allow-ping"]

  depends_on = [
    module.vpc_workload
  ]

  allow_stopping_for_update = true
}