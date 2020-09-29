resource "google_compute_network" "this" {
  for_each                        = var.network
  name                            = each.value.name
  delete_default_routes_on_create = try(each.value.delete_default_routes_on_create, false)
  auto_create_subnetworks         = false
}

resource "google_compute_subnetwork" "this" {
  for_each      = var.network
  name          = each.value.name
  ip_cidr_range = each.value.ip_cidr_range
  network       = google_compute_network.this[each.key].self_link
}

resource "google_compute_firewall" "this" {
  for_each      = { for k, v in var.network: k => v if can(v.allowed_sources) }
  name          = "${each.value.name}-ingress"
  network       = google_compute_network.this[each.key].self_link
  direction     = "INGRESS"
  source_ranges = each.value.allowed_sources

  allow {
    protocol = try(each.value.allowed_protocol, var.allowed_protocol, null)
    ports    = try(each.value.allowed_ports, var.allowed_ports, null)
  }
}
