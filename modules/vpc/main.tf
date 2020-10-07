locals {
  networks = { for v in var.networks : v.name => v } // tested on tf-0.12, when list elements shift indexes, this map prevents destroy
  networks_to_create = { for k, v in local.networks
    : k => v
    if ! (try(v.create_network == false, false))
  }
  networks_to_gather = { for k, v in local.networks
    : k => v
    if try(v.create_network == false, false)
  }
}

data "google_compute_network" "this" {
  for_each = local.networks_to_gather
  name     = each.value.name
}

resource "google_compute_network" "this" {
  for_each                        = local.networks_to_create
  name                            = each.value.name
  delete_default_routes_on_create = try(each.value.delete_default_routes_on_create, false)
  auto_create_subnetworks         = false
}

resource "google_compute_subnetwork" "this" {
  for_each      = { for v in var.networks : "${v.name}-${var.region}" => v }
  name          = "${each.value.name}-${var.region}"
  ip_cidr_range = each.value.ip_cidr_range
  network       = try(google_compute_network.this[each.value.name].self_link, data.google_compute_network.this[each.value.name].self_link)
  region        = var.region
}

resource "google_compute_firewall" "this" {
  for_each      = { for k, v in local.networks : k => v if can(v.allowed_sources) }
  name          = "${each.value.name}-ingress"
  network       = try(google_compute_network.this[each.key].self_link, data.google_compute_network.this[each.key].self_link)
  direction     = "INGRESS"
  source_ranges = each.value.allowed_sources

  allow {
    protocol = try(each.value.allowed_protocol, var.allowed_protocol, null)
    ports    = try(each.value.allowed_ports, var.allowed_ports, null)
  }
}
