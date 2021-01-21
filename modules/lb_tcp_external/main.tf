terraform {
  required_providers {
    google = { version = "~> 3.30" }
  }
}

resource "google_compute_address" "this" {
  for_each = { for k, v in var.rules : k => v if ! can(v.ip_address) }

  name         = each.key
  address_type = "EXTERNAL"
  region       = var.region
  project      = var.project
}

resource "google_compute_forwarding_rule" "rule" {
  for_each = var.rules

  name                  = each.key
  target                = google_compute_target_pool.this.self_link
  load_balancing_scheme = "EXTERNAL"
  port_range            = each.value.port_range
  ip_address            = lookup(each.value, "ip_address", google_compute_address.this[each.key].address)
  ip_protocol           = lookup(each.value, "ip_protocol", "TCP")
  region                = var.region
  project               = var.project
}

resource "google_compute_target_pool" "this" {
  name             = var.name
  session_affinity = var.session_affinity
  instances        = var.instances
  health_checks    = var.create_health_check ? [google_compute_http_health_check.this[0].self_link] : []
  region           = var.region
  project          = var.project

  lifecycle {
    # Ignore changes because autoscaler changes this in the background.
    ignore_changes = [instances]
  }
}

data "google_client_config" "this" {}

locals {
  # If we were told an exact region, use it, otherwise fall back to a client-default region
  region = coalesce(var.region, data.google_client_config.this.region)
}

resource "google_compute_http_health_check" "this" {
  count = var.create_health_check ? 1 : 0

  name                = "${var.name}-${local.region}"
  check_interval_sec  = var.health_check_interval_sec
  healthy_threshold   = var.health_check_healthy_threshold
  timeout_sec         = var.health_check_timeout_sec
  unhealthy_threshold = var.health_check_unhealthy_threshold
  port                = var.health_check_http_port
  request_path        = var.health_check_http_request_path
  host                = var.health_check_http_host
  project             = var.project
}
