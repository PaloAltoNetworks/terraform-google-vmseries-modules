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
  ip_address            = try(each.value.ip_address, google_compute_address.this[each.key].address, null)
  ip_protocol           = try(each.value.ip_protocol, "TCP")
  region                = var.region
  project               = var.project
}

resource "google_compute_target_pool" "this" {
  name             = var.name
  session_affinity = var.session_affinity
  instances        = var.instances
  health_checks    = var.disable_health_check ? [] : [google_compute_http_health_check.this[0].self_link]
  region           = var.region
  project          = var.project

  lifecycle {
    # Ignore changes because autoscaler changes this in the background.
    ignore_changes = [instances]
  }
}

resource "google_compute_http_health_check" "this" {
  count = var.disable_health_check ? 0 : 1

  name                = "${var.name}-hc"
  check_interval_sec  = var.health_check_interval_sec
  healthy_threshold   = var.health_check_healthy_threshold
  timeout_sec         = var.health_check_timeout_sec
  unhealthy_threshold = var.health_check_unhealthy_threshold
  port                = var.health_check_port
  request_path        = var.health_check_request_path
  host                = var.health_check_host
  project             = var.project
}
