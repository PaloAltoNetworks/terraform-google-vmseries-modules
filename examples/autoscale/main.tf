locals {
  prefix = var.prefix != null && var.prefix != "" ? "${var.prefix}-" : ""
}

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
}

# Create VM-Series managed instance group for autoscaling
module "autoscale" {
  source = "../../modules/autoscale/"

  name                   = "${local.prefix}vmseries"
  region                 = var.region
  use_regional_mig       = true
  min_vmseries_replicas  = var.vmseries_instances_min // min firewalls per region.
  max_vmseries_replicas  = var.vmseries_instances_max // max firewalls per region.
  image                  = var.vmseries_image_name
  machine_type           = var.vmseries_machine_type
  create_pubsub_topic    = true
  target_pool_self_links = [module.extlb.target_pool]
  service_account_email  = module.iam_service_account.email
  autoscaler_metrics     = var.autoscaler_metrics

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
    dns-primary                 = "169.254.169.254" // Google DNS required to deliver PAN-OS metrics to Cloud Monitoring
    dns-secondary               = "4.2.2.2"
  }

  depends_on = [
    module.mgmt_cloud_nat
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

  name              = "${local.prefix}internal-lb"
  network           = module.vpc_trust.network_id
  subnetwork        = module.vpc_trust.subnets_self_links[0]
  all_ports         = true
  health_check_port = 80
  backends = {
    backend = module.autoscale.regional_instance_group_id
  }
  allow_global_access = true
}

#-----------------------------------------------------------------------------------------------
#  External Network Load Balancer to distribute traffic to VM-Series untrust interfaces
#-----------------------------------------------------------------------------------------------

module "extlb" {
  source = "../../modules/lb_external/"

  name  = "${local.prefix}external-lb"
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
