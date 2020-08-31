resource "google_compute_health_check" "default" {
  name = "${var.name}-check-tcp${var.health_check_port}"

  tcp_health_check {
    port = var.health_check_port
  }
}

resource "google_compute_region_backend_service" "default" {
  name          = var.name
  health_checks = [google_compute_health_check.default.self_link]
  network       = var.network

  dynamic "backend" {
    for_each = var.backends
    content {
      group    = lookup(backend.value, "group")
      failover = lookup(backend.value, "failover")
    }
  }
  session_affinity = "NONE"
}

resource "google_compute_forwarding_rule" "default" {
  name                  = var.name
  load_balancing_scheme = "INTERNAL"
  ip_address            = var.ip_address
  ip_protocol           = var.ip_protocol
  all_ports             = var.all_ports
  ports                 = var.ports
  subnetwork            = var.subnetwork
  backend_service       = google_compute_region_backend_service.default.self_link
}
