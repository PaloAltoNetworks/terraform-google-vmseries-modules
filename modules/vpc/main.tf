locals {
  network = { for v in var.network : v.name => v } // tested on tf-0.12, when list elements shift indexes, this map prevents destroy
}

resource "google_compute_network" "this" {
  for_each                        = local.network
  name                            = each.value.name
  delete_default_routes_on_create = try(each.value.delete_default_routes_on_create, false)
  auto_create_subnetworks         = false
}

data "google_client_config" "this" {}

locals {
  region = var.region == null || var.region == "" ? data.google_client_config.this.region : var.region
}

resource "google_compute_subnetwork" "this" {
  for_each      = { for k, v in var.network: k => v }
  name          = "${each.value.name}-${local.region}"
  ip_cidr_range = each.value.ip_cidr_range
  network       = google_compute_network.this[each.value.name].self_link
}

resource "google_compute_firewall" "this" {
  for_each      = { for k, v in local.network : k => v if can(v.allowed_sources) }
  name          = "${each.value.name}-ingress"
  network       = google_compute_network.this[each.key].self_link
  direction     = "INGRESS"
  source_ranges = each.value.allowed_sources

  allow {
    protocol = try(each.value.allowed_protocol, var.allowed_protocol, null)
    ports    = try(each.value.allowed_ports, var.allowed_ports, null)
  }
}
