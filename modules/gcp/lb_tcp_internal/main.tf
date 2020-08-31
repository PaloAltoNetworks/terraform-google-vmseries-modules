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
      group    = backend.value
      failover = false
    }
  }

  dynamic "backend" {
    for_each = var.failover_backends
    content {
      group    = backend.value
      failover = true
    }
  }

  session_affinity = "NONE"
  failover_policy {
    disable_connection_drain_on_failover = var.disable_connection_drain_on_failover
    drop_traffic_if_unhealthy            = var.drop_traffic_if_unhealthy
    failover_ratio                       = var.failover_ratio
  }
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
