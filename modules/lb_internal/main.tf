data "google_client_config" "this" {}

resource "google_compute_health_check" "this" {
  name = "${var.name}-${data.google_client_config.this.region}-check-tcp${var.health_check_port}"

  timeout_sec      = var.timeout_sec
  check_interval_sec  = var.check_interval_sec
  healthy_threshold   = var.healthy_threshold
  unhealthy_threshold = var.unhealthy_threshold


  tcp_health_check {
    port = var.health_check_port
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_backend_service" "this" {
  provider = google-beta

  name             = var.name
  health_checks    = [var.health_check != null ? var.health_check : google_compute_health_check.this.self_link]
  network          = var.network
  session_affinity = var.session_affinity

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

  dynamic "failover_policy" {
    for_each = var.disable_connection_drain_on_failover != null || var.drop_traffic_if_unhealthy != null || var.failover_ratio != null ? ["one"] : []

    content {
      disable_connection_drain_on_failover = var.disable_connection_drain_on_failover
      drop_traffic_if_unhealthy            = var.drop_traffic_if_unhealthy
      failover_ratio                       = var.failover_ratio
    }
  }

  connection_tracking_policy {
    tracking_mode                                = var.connection_tracking_mode
    connection_persistence_on_unhealthy_backends = var.connection_persistence_on_unhealthy_backends
    idle_timeout_sec                             = var.connection_idle_timeout_sec
  }
}

resource "google_compute_forwarding_rule" "this" {
  name                  = var.name
  load_balancing_scheme = "INTERNAL"
  ip_address            = var.ip_address
  ip_protocol           = var.ip_protocol
  all_ports             = var.all_ports
  ports                 = var.ports
  subnetwork            = var.subnetwork
  allow_global_access   = var.allow_global_access
  backend_service       = google_compute_region_backend_service.this.self_link
}
