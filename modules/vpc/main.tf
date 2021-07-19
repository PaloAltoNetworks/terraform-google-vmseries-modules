locals {
  // All the networks:
  networks = { for v in var.networks : v.name => v } // tested on tf-0.12, when list elements shift indexes, this map prevents destroy

  // Some networks already exist:
  networks_existing = {
    for k, v in local.networks
    : k => v
    if try(v.create_network == false, false)
  }

  // Some networks need to be created:
  networks_to_create = {
    for k, v in local.networks
    : k => v
    if !(try(v.create_network == false, false))
  }

  // We have networks, now the same for subnetworks:
  subnetworks = { for v in var.networks : v.subnetwork_name => v }

  // Some subnetworks already exist:
  subnetworks_existing = {
    for k, v in local.subnetworks
    : k => v
    if try(v.create_subnetwork == false, false)
  }

  // Some subnetworks need to be created:
  subnetworks_to_create = {
    for k, v in local.subnetworks
    : k => v
    if !(try(v.create_subnetwork == false, false))
  }
}

data "google_compute_network" "this" {
  for_each = local.networks_existing
  name     = each.value.name
  project  = try(each.value.host_project_id, null)
}

resource "google_compute_network" "this" {
  for_each                        = local.networks_to_create
  name                            = each.value.name
  project                         = try(each.value.host_project_id, null)
  delete_default_routes_on_create = try(each.value.delete_default_routes_on_create, false)
  auto_create_subnetworks         = false
}

data "google_compute_subnetwork" "this" {
  for_each = local.subnetworks_existing
  name     = each.value.subnetwork_name
  project  = try(each.value.host_project_id, null)
  region   = var.region
}

resource "google_compute_subnetwork" "this" {
  for_each                 = local.subnetworks_to_create
  name                     = each.value.subnetwork_name
  ip_cidr_range            = each.value.ip_cidr_range
  network                  = merge(google_compute_network.this, data.google_compute_network.this)[each.value.name].self_link
  region                   = var.region
  private_ip_google_access = true
}

resource "google_compute_firewall" "this" {
  for_each      = { for k, v in local.networks : k => v if can(v.allowed_sources) }
  name          = "${each.value.name}-ingress"
  network       = merge(google_compute_network.this, data.google_compute_network.this)[each.key].self_link
  direction     = "INGRESS"
  source_ranges = each.value.allowed_sources

  allow {
    protocol = try(each.value.allowed_protocol, var.allowed_protocol, null)
    ports    = try(each.value.allowed_ports, var.allowed_ports, null)
  }

  dynamic "log_config" {
    for_each = compact(try([each.value.log_metadata], []))

    content {
      metadata = log_config.value
    }
  }
}
