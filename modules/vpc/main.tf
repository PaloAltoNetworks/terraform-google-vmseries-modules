resource "google_compute_network" "this" {
  for_each                        = var.network
  name                            = each.value.name
  delete_default_routes_on_create = try(each.value.delete_default_routes_on_create, false)
  auto_create_subnetworks         = false
}

resource "google_compute_subnetwork" "this" {
  for_each      = var.subnetworks
  name          = each.value.name
  ip_cidr_range = each.value.ip_cidr_range
  network       = google_compute_network.this.self_link
  region        = lookup(each.value, "region", null)
}

resource "google_compute_firewall" "this" {
  count         = length(var.allowed_sources) != 0 ? 1 : 0
  name          = "${google_compute_network.this.name}-ingress"
  network       = google_compute_network.this.self_link
  direction     = "INGRESS"
  source_ranges = var.allowed_sources

  allow {
    protocol = var.allowed_protocol
    ports    = var.allowed_ports
  }
}
