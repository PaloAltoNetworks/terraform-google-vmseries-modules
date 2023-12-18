module "iam_service_account" {
  source = "../../modules/iam_service_account"

  for_each = var.service_accounts

  service_account_id = "${var.name_prefix}${each.value.service_account_id}"
  display_name       = "${var.name_prefix}${each.value.display_name}"
  roles              = each.value.roles
  project_id         = var.project
}

module "vpc" {
  source = "../../modules/vpc"

  for_each = var.networks

  project_id                      = var.project
  name                            = "${var.name_prefix}${each.value.vpc_name}"
  create_network                  = each.value.create_network
  delete_default_routes_on_create = each.value.delete_default_routes_on_create
  mtu                             = each.value.mtu
  routing_mode                    = each.value.routing_mode
  subnetworks = { for k, v in each.value.subnetworks : k => merge(v, {
    name = "${var.name_prefix}${v.name}"
    })
  }
  firewall_rules = try({ for k, v in each.value.firewall_rules : k => merge(v, {
    name = "${var.name_prefix}${v.name}"
    })
  }, {})
}

resource "google_compute_route" "this" {

  for_each = var.routes

  name         = "${var.name_prefix}${each.value.name}"
  dest_range   = each.value.destination_range
  network      = module.vpc[each.value.vpc_network_key].network.self_link
  next_hop_ilb = module.lb_internal[each.value.lb_internal_key].forwarding_rule
  priority     = 100
}

module "vpc_peering" {
  source = "../../modules/vpc-peering"

  for_each = var.vpc_peerings

  local_network = module.vpc[each.value.local_network_key].network.id
  peer_network  = module.vpc[each.value.peer_network_key].network.id

  local_export_custom_routes                = each.value.local_export_custom_routes
  local_import_custom_routes                = each.value.local_import_custom_routes
  local_export_subnet_routes_with_public_ip = each.value.local_export_subnet_routes_with_public_ip
  local_import_subnet_routes_with_public_ip = each.value.local_import_subnet_routes_with_public_ip

  peer_export_custom_routes                = each.value.peer_export_custom_routes
  peer_import_custom_routes                = each.value.peer_import_custom_routes
  peer_export_subnet_routes_with_public_ip = each.value.peer_export_subnet_routes_with_public_ip
  peer_import_subnet_routes_with_public_ip = each.value.peer_import_subnet_routes_with_public_ip
}

module "autoscale" {
  source = "../../modules/autoscale/"

  for_each = var.autoscale

  name                             = "${var.name_prefix}${each.value.name}"
  region                           = var.region
  project_id                       = var.project
  regional_mig                     = try(var.autoscale_regional_mig, true)
  zones                            = try(each.value.zones, {})
  image                            = "https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/${try(each.value.image, var.autoscale_common.image)}"
  named_ports                      = try(each.value.named_ports, var.autoscale_common.named_ports)
  machine_type                     = try(each.value.machine_type, var.autoscale_common.machine_type)
  min_cpu_platform                 = try(each.value.min_cpu_platform, var.autoscale_common.min_cpu_platform, "Intel Cascade Lake")
  disk_type                        = try(each.value.disk_type, var.autoscale_common.disk_type, "pd-ssd")
  service_account_email            = try(module.iam_service_account[each.value.service_account_key].email, module.iam_service_account[var.autoscale_common.service_account_key].email)
  scopes                           = try(each.value.scopes, var.autoscale_common.scopes, [])
  tags                             = try(each.value.tags, var.autoscale_common.tags, [])
  update_policy_type               = try(each.value.update_policy_type, var.autoscale_common.update_policy_type, "OPPORTUNISTIC")
  min_vmseries_replicas            = try(each.value.min_vmseries_replicas, var.autoscale_common.min_vmseries_replicas)
  max_vmseries_replicas            = try(each.value.max_vmseries_replicas, var.autoscale_common.max_vmseries_replicas)
  cooldown_period                  = try(each.value.cooldown_period, var.autoscale_common.cooldown_period, 480)
  scale_in_control_time_window_sec = try(each.value.scale_in_control_time_window_sec, var.autoscale_common.scale_in_control_time_window_sec, 1800)
  scale_in_control_replicas_fixed  = try(each.value.scale_in_control_replicas_fixed, var.autoscale_common.scale_in_control_replicas_fixed, 1)
  create_pubsub_topic              = try(each.value.create_pubsub_topic, var.autoscale_common.create_pubsub_topic)
  autoscaler_metrics = try(each.value.autoscaler_metrics, var.autoscale_common.autoscaler_metrics,
    {
      "custom.googleapis.com/VMSeries/panSessionUtilization" = {
        target = 70
      }
      "custom.googleapis.com/VMSeries/panSessionThroughputKbps" = {
        target = 700000
      }
  })

  network_interfaces = [for v in each.value.network_interfaces :
    {
      subnetwork       = module.vpc[v.vpc_network_key].subnetworks[v.subnetwork_key].self_link
      create_public_ip = try(v.create_public_ip, false)
      public_ip        = try(v.public_ip, null)
  }]
  metadata = merge(
    try(each.value.bootstrap_options, {}),
    try(var.autoscale_common.bootstrap_options, {})
  )
}

data "google_compute_image" "my_image" {
  family  = "ubuntu-pro-2204-lts"
  project = "ubuntu-os-pro-cloud"
}

resource "google_compute_instance" "linux_vm" {
  for_each = var.linux_vms

  name         = "${var.name_prefix}${each.key}"
  machine_type = each.value.linux_machine_type
  zone         = each.value.zone

  boot_disk {
    initialize_params {
      image = data.google_compute_image.my_image.id
      size  = each.value.linux_disk_size
    }
  }

  network_interface {
    subnetwork = module.vpc[each.value.vpc_network_key].subnetworks[each.value.subnetwork_key].self_link
    network_ip = each.value.private_ip
  }

  metadata = {
    enable-oslogin = true
  }


  service_account {
    email  = module.iam_service_account[each.value.service_account_key].email
    scopes = each.value.scopes
  }
}

module "lb_internal" {
  source = "../../modules/lb_internal"

  for_each = var.lbs_internal

  name              = "${var.name_prefix}${each.value.name}"
  region            = var.region
  health_check_port = try(each.value.health_check_port, "80")
  backends = var.autoscale_regional_mig ? { for v in each.value.backends : v => module.autoscale[v].regional_instance_group_id } : merge([
    for v in each.value.backends :
    {
      for z_k, z_v in var.autoscale[v].zones :
      "${v}_${z_k}" => module.autoscale[v].zonal_instance_group_ids[z_k]
    }
  ]...)
  subnetwork = module.vpc[each.value.vpc_network_key].subnetworks[each.value.subnetwork_key].self_link
  network    = module.vpc[each.value.vpc_network_key].network.self_link
  all_ports  = true
}

module "lb_external" {
  source = "../../modules/lb_external"

  for_each = var.lbs_external

  project = var.project

  name = "${var.name_prefix}${each.value.name}"
  backend_instance_groups = var.autoscale_regional_mig ? { for v in each.value.backends : v => module.autoscale[v].regional_instance_group_id } : merge([
    for v in each.value.backends :
    {
      for z_k, z_v in var.autoscale[v].zones :
      "${v}_${z_k}" => module.autoscale[v].zonal_instance_group_ids[z_k]
    }
  ]...)
  rules = each.value.rules

  health_check_http_port         = each.value.http_health_check_port
  health_check_http_request_path = try(each.value.http_health_check_request_path, "/php/login.php")
}