terraform {
  required_providers {
    google = { version = "~> 3.30" }
  }
}

resource "google_compute_forwarding_rule" "this" {
  name                  = var.name
  target                = google_compute_target_pool.this.self_link
  load_balancing_scheme = "EXTERNAL"
  port_range            = var.service_port
  ip_address            = var.ip_address
  ip_protocol           = var.ip_protocol
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
}

resource "google_compute_http_health_check" "this" {
  count = var.disable_health_check ? 0 : 1

  name                = "${var.name}-hc"
  check_interval_sec  = var.health_check["check_interval_sec"]
  healthy_threshold   = var.health_check["healthy_threshold"]
  timeout_sec         = var.health_check["timeout_sec"]
  unhealthy_threshold = var.health_check["unhealthy_threshold"]
  port                = coalesce(var.health_check["port"], var.service_port)
  request_path        = var.health_check["request_path"]
  host                = var.health_check["host"]
  project             = var.project
}
