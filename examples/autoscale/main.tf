locals {
  prefix = var.prefix != null && var.prefix != "" ? "${var.prefix}-" : ""
}

data "google_compute_zones" "main" {}


#-----------------------------------------------------------------------------------------------
# Create Mgmt, untrust, and trust VPC networks.  
#-----------------------------------------------------------------------------------------------
/*
  It is recommended to have your management network already configured with network access
  to Panorama.  All autoscale deployments require Panorama.  It is recommended to have the 
  management network preconfigured with network access to Panorama. 
*/

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

#-----------------------------------------------------------------------------------------------
# Firewalls with auto-scaling.
#-----------------------------------------------------------------------------------------------
/*
  Dedicated IAM service account for running GCP instances of Palo Alto Networks VM-Series.
  The account is used for running the instances and for also for their GCP plugin access.
*/

module "iam_service_account" {
  source = "../../modules/iam_service_account/"

  service_account_id = "${local.prefix}vmseries-mig-sa"
  project_id         = var.project_id
}

# Create VM-Series managed instance group for autoscaling
module "autoscale" {
  source = "../../modules/autoscale"

  zones = {
    zone1 = data.google_compute_zones.main.names[0]
    zone2 = data.google_compute_zones.main.names[1]
  }

  prefix                = "${local.prefix}vmseries-mig"
  deployment_name       = "${local.prefix}vmseries-mig-deployment"
  machine_type          = var.vmseries_machine_type
  image                 = var.vmseries_image_name
  pool                  = module.extlb.target_pool
  scopes                = ["https://www.googleapis.com/auth/cloud-platform"]
  service_account_email = module.iam_service_account.email
  min_replicas_per_zone = var.vmseries_per_zone_min // min firewalls per zone.
  max_replicas_per_zone = var.vmseries_per_zone_max // max firewalls per zone.
  autoscaler_metrics    = var.autoscaler_metrics

  network_interfaces = [
    {
      subnetwork       = module.vpc_untrust.subnets_self_links[0]
      create_public_ip = true // Used for outbound internet traffic.
    },
    {
      subnetwork       = module.vpc_mgmt.subnets_self_links[0]
      create_public_ip = false // Set to true if you want to access the firewalls over the internet (not recommended).
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
    dns-primary                 = "8.8.8.8"
    dns-secondary               = "4.2.2.2"
  }

  # Example of full bootstrap with Google storage bucket.
  /*
  metadata = {
    mgmt-interface-swap                  = "enable"
    vmseries-bootstrap-gce-storagebucket = "my-google-bootstrap-bucket"
    serial-port-enable                   = true
    ssh-keys                             = "~/.ssh/vmseries-ssh-key.pub"
  }
  */
  named_ports = [
    {
      name = "http"
      port = "80"
    },
  ]
}


#-----------------------------------------------------------------------------------------------
# Internal Network Balancer to distribute traffic to VM-Series trust interfaces
#-----------------------------------------------------------------------------------------------
/* 
  The load balancers are not required for this example.  It is here to provide an example
  of how to use the load balancer modules. 
*/

module "intlb" {
  source = "../../modules/lb_internal/"

  name                = "${local.prefix}intlb"
  network             = module.vpc_trust.network_id
  subnetwork          = module.vpc_trust.subnets_self_links[0]
  all_ports           = true
  backends            = module.autoscale.backends
  allow_global_access = true
}

#-----------------------------------------------------------------------------------------------
#  External Network Load Balancer to distribute traffic to VM-Series untrust interfaces
#-----------------------------------------------------------------------------------------------

module "extlb" {
  source = "../../modules/lb_external/"

  name  = "${local.prefix}extlb"
  rules = { ("${local.prefix}rule0") = { port_range = 80 } }

  health_check_http_port         = 80
  health_check_http_request_path = "/"
}

# -----------------------------------------------------------------------------------------------
# Cloud Nat for the management interfaces.
# -----------------------------------------------------------------------------------------------
/* 
  Cloud NAT is required in teh management network to provide connectivity to Cortex Data Lake
  and to license the VM-Series from the PANW licensing servers.
*/

module "mgmt_cloud_nat" {
  source  = "terraform-google-modules/cloud-nat/google"
  version = "=1.2"

  name          = "${local.prefix}mgmt-nat"
  project_id    = var.project_id
  region        = var.region
  create_router = true
  router        = "${local.prefix}mgmt-router"
  network       = module.vpc_mgmt.network_id
}
