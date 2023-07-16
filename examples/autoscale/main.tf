# Create mgmt, untrust, and trust VPC networks.  
# It is recommended to have the management network preconfigured with network access
# to Panorama. All autoscale deployments require Panorama.
module "vpc_mgmt" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 4.0"
  project_id   = var.project_id
  network_name = "${var.name_prefix}mgmt-vpc"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name   = "${var.name_prefix}${var.region}-mgmt"
      subnet_ip     = var.cidr_mgmt
      subnet_region = var.region
    }
  ]

  firewall_rules = [
    {
      name        = "${var.name_prefix}vmseries-mgmt"
      direction   = "INGRESS"
      priority    = "100"
      description = "Allow ingress access to VM-Series management interface"
      ranges      = var.allowed_sources
      allow = [
        {
          protocol = "tcp"
          ports    = ["22", "443", "3978"]
        }
      ]
    }
  ]
}

module "vpc_untrust" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 4.0"
  project_id   = var.project_id
  network_name = "${var.name_prefix}untrust-vpc"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name   = "${var.name_prefix}${var.region}-untrust"
      subnet_ip     = var.cidr_untrust
      subnet_region = var.region
    }
  ]

  firewall_rules = [
    {
      name      = "${var.name_prefix}allow-all-untrust"
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
  network_name                           = "${var.name_prefix}trust-vpc"
  routing_mode                           = "GLOBAL"
  delete_default_internet_gateway_routes = true

  subnets = [
    {
      subnet_name   = "${var.name_prefix}${var.region}-trust"
      subnet_ip     = var.cidr_trust
      subnet_region = var.region
    }
  ]

  firewall_rules = [
    {
      name      = "${var.name_prefix}allow-all-trust"
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

# IAM service account for running GCP instances of Palo Alto Networks VM-Series and their GCP plugin access.
module "iam_service_account" {
  source = "../../modules/iam_service_account/"

  project_id         = var.project_id
  service_account_id = "${var.name_prefix}vmseries-mig-sa"
}

# Create VM-Series managed instance group for autoscaling
module "autoscale" {
  source = "../../modules/autoscale/"

  name                  = "${var.name_prefix}vmseries"
  region                = var.region
  regional_mig          = true
  create_pubsub_topic   = true
  autoscaler_metrics    = var.autoscaler_metrics
  min_vmseries_replicas = var.vmseries_instances_min # min firewalls per region.
  max_vmseries_replicas = var.vmseries_instances_max # max firewalls per region.
  image                 = var.vmseries_image_name
  machine_type          = var.vmseries_machine_type
  service_account_email = module.iam_service_account.email
  target_pools          = [module.extlb.target_pool]

  network_interfaces = [
    {
      subnetwork       = module.vpc_untrust.subnets_self_links[0]
      create_public_ip = true
    },
    {
      subnetwork       = module.vpc_mgmt.subnets_self_links[0]
      create_public_ip = false
    },
    {
      subnetwork       = module.vpc_trust.subnets_self_links[0]
      create_public_ip = false
    }
  ]

  metadata = {
    type                        = "dhcp-client"
    op-command-modes            = "mgmt-interface-swap"
    vm-auth-key                 = var.panorama_vm_auth_key
    panorama-server             = var.panorama_address
    dgname                      = var.panorama_device_group
    tplname                     = var.panorama_template_stack
    dhcp-send-hostname          = "yes"
    dhcp-send-client-id         = "yes"
    dhcp-accept-server-hostname = "yes"
    dhcp-accept-server-domain   = "yes"
    dns-primary                 = "169.254.169.254" # Google DNS required to deliver PAN-OS metrics to Cloud Monitoring
    ssh-keys                    = var.ssh_keys
  }

  depends_on = [
    module.mgmt_cloud_nat
  ]
}

# Internal Network Load Balancer to distribute traffic to VM-Series trust interfaces
module "intlb" {
  source = "../../modules/lb_internal/"

  name              = "${var.name_prefix}internal-lb"
  network           = module.vpc_trust.network_id
  subnetwork        = module.vpc_trust.subnets_self_links[0]
  all_ports         = true
  health_check_port = 80
  backends = {
    backend = module.autoscale.regional_instance_group_id
  }
  allow_global_access = true
}

# External Network Load Balancer to distribute traffic to VM-Series untrust interfaces
module "extlb" {
  source = "../../modules/lb_external/"

  name  = "${var.name_prefix}external-lb"
  rules = { ("${var.name_prefix}rule0") = { port_range = 80 } }

  health_check_http_port         = 80
  health_check_http_request_path = "/"
}

# Cloud NAT for the management interfaces. It is required in the management network to provide
# connectivity to Cortex Data Lakeand to license the VM-Series from the PANW licensing servers.
module "mgmt_cloud_nat" {
  source  = "terraform-google-modules/cloud-nat/google"
  version = "=1.2"

  name          = "${var.name_prefix}mgmt-nat"
  project_id    = var.project_id
  region        = var.region
  create_router = true
  router        = "${var.name_prefix}mgmt-router"
  network       = module.vpc_mgmt.network_id
}
