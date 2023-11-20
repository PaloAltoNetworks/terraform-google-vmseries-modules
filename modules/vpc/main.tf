locals {
  subnetworks_existing = {
    for k, v in var.subnetworks
    : k => v
    if try(v.create_subnetwork == false, false)
  }

  // Some subnetworks need to be created:
  subnetworks_to_create = {
    for k, v in var.subnetworks
    : k => v
    if !(try(v.create_subnetwork == false, false))
  }
}

data "google_compute_network" "this" {
  count = var.create_network == true ? 0 : 1

  name    = var.name
  project = try(var.project_id, null)
}

resource "google_compute_network" "this" {
  count = var.create_network == true ? 1 : 0

  name                            = var.name
  project                         = try(var.project_id, null)
  delete_default_routes_on_create = try(var.delete_default_routes_on_create, false)
  mtu                             = try(var.mtu, null)
  auto_create_subnetworks         = false
  routing_mode                    = try(var.routing_mode, null)
}

data "google_compute_subnetwork" "this" {
  for_each = local.subnetworks_existing

  name    = each.value.subnetwork_name
  project = try(var.project_id, null)
  region  = try(each.value.region, null)
}

resource "google_compute_subnetwork" "this" {
  for_each = local.subnetworks_to_create

  name          = each.value.subnetwork_name
  ip_cidr_range = each.value.ip_cidr_range
  network       = try(data.google_compute_network.this[0].self_link, google_compute_network.this[0].self_link)
  region        = try(each.value.region, null)
  project       = try(var.project_id, null)
}

resource "google_compute_firewall" "this" {
  for_each = var.firewall_rules

  name                    = "${each.value.name}-ingress"
  network                 = try(data.google_compute_network.this[0].self_link, google_compute_network.this[0].self_link)
  direction               = "INGRESS"
  source_ranges           = try(each.value.source_ranges, null)
  source_tags             = try(each.value.source_tags, null)
  source_service_accounts = try(each.value.source_service_accounts, null)
  project                 = try(var.project_id, null)
  priority                = try(each.value.priority, null)
  target_service_accounts = try(each.value.target_service_accounts, null)
  target_tags             = try(each.value.target_tags, null)


  allow {
    protocol = try(each.value.allowed_protocol, null)
    ports    = try(each.value.allowed_ports, null)
  }

  dynamic "log_config" {
    for_each = compact(try([each.value.log_metadata], []))

    content {
      metadata = log_config.value
    }
  }
  lifecycle {
    precondition {
      condition = (
        (can(each.value.source_ranges) && !can(each.value.source_tags) && !can(each.value.source_service_accounts)) ||
        (!can(each.value.source_ranges) && can(each.value.source_tags) && !can(each.value.source_service_accounts)) ||
        (!can(each.value.source_ranges) && !can(each.value.source_tags) && can(each.value.source_service_accounts)) ||
        (!can(each.value.source_ranges) && !can(each.value.source_tags) && !can(each.value.source_service_accounts))
      )
      error_message = "Please select only one of the three options: source_service_accounts, source_ranges, source_tags!"
    }
  }
}