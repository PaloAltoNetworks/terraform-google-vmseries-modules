locals {
  prefix = var.prefix != null && var.prefix != "" ? "${var.prefix}-" : ""
}

#-----------------------------------------------------------------------------------------------
# Retrieve data resouce information from existing VPCs & subnetworks.
#-----------------------------------------------------------------------------------------------

data "google_compute_subnetwork" "mgmt" {
  name   = var.existing_mgmt_subnet_name
  region = var.region
}

data "google_compute_subnetwork" "untrust" {
  name   = var.existing_untrust_subnet_name
  region = var.region
}

data "google_compute_subnetwork" "trust" {
  name   = var.existing_trust_subnet_name
  region = var.region
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
      subnetwork       = data.google_compute_subnetwork.untrust.self_link
      create_public_ip = true
    },
    {
      subnetwork       = data.google_compute_subnetwork.mgmt.self_link
      create_public_ip = false
    },
    {
      subnetwork       = data.google_compute_subnetwork.trust.self_link
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
  network           = data.google_compute_subnetwork.trust.network
  subnetwork        = data.google_compute_subnetwork.trust.self_link
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
