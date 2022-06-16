terraform {
  required_providers {
    google = { version = "~> 3.30" }
  }
}

data "google_client_config" "this" {}

locals {
  # If we were told an exact region, use it, otherwise fall back to a client-default region
  region = coalesce(var.region, data.google_client_config.this.region)

  # Check for `L3_DEFAULT` as this requires a `google_compute_region_backend_service` resource and `google_compute_region_health_check` health check
  backend_service_needed = contains([for v in values(var.rules) : lookup(v, "ip_protocol", null)], "L3_DEFAULT")

  # Check for protocols that require a `google_compute_target_pool` backend and `google_compute_http_health_check` health check
  target_pool_protocols = ["TCP", "UDP", "ESP", "AH", "SCTP", "ICMP"]
  target_pool_needed    = contains([for v in values(var.rules) : contains(local.target_pool_protocols, lookup(v, "ip_protocol", "TCP"))], true)
}

# Create external IP addresses if non-specified
resource "google_compute_address" "this" {
  for_each = { for k, v in var.rules : k => v if !can(v.ip_address) }

  name         = each.key
  address_type = "EXTERNAL"
  region       = var.region
  project      = var.project
}

# Create forwarding rule for each specified rule
resource "google_compute_forwarding_rule" "rule" {
  for_each = var.rules

  name    = each.key
  project = var.project
  region  = var.region

  # Check if `ip_protocol` is specified (if not assume default of `TCP`) != `L3_DEFAULT` if true then use `google_compute_target_pool` as backend
  target = lookup(each.value, "ip_protocol", "TCP") != "L3_DEFAULT" ? google_compute_target_pool.this[0].self_link : null

  # Check if `ip_protocol` is specified (if not assume default of `TCP`) == `L3_DEFAULT` if true then use `google_compute_region_backend_service` as backend
  backend_service       = lookup(each.value, "ip_protocol", "TCP") == "L3_DEFAULT" ? google_compute_region_backend_service.this[0].self_link : null
  load_balancing_scheme = "EXTERNAL"

  # Check if `ip_protocol` is specified (if not assume default of `TCP`) == `L3_DEFAULT`.
  #   If true then set `all_ports` to `true`.
  #   If false set value to the value of `all_ports`. If `all_ports` isn't specified, then set the value to `null`.
  all_ports = lookup(each.value, "ip_protocol", "TCP") == "L3_DEFAULT" ? true : lookup(each.value, "all_ports", null)

  # Check if `ip_protocol` is specified (if not assume default of `TCP`) == `L3_DEFAULT`.
  #   If true then set `port_range` to `null`.
  #   If false set value to the value of `port_range`. If `port_range` isn't specified, then set the value to `null`.
  port_range = lookup(each.value, "ip_protocol", "TCP") == "L3_DEFAULT" ? null : lookup(each.value, "port_range", null)

  ip_address  = lookup(each.value, "ip_address", google_compute_address.this[each.key].address)
  ip_protocol = lookup(each.value, "ip_protocol", "TCP")
}

# Create `google_compute_target_pool` if required by `var.rules`
resource "google_compute_target_pool" "this" {
  count            = local.target_pool_needed ? 1 : 0
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

# Create `google_compute_http_health_check` if required by `var.rules`
resource "google_compute_http_health_check" "this" {
  count = var.create_health_check && local.target_pool_needed ? 1 : 0

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

# Create `google_compute_region_backend_service` if require by `var.rules`
resource "google_compute_region_backend_service" "this" {
  provider = google-beta

  count = local.backend_service_needed ? 1 : 0

  name                  = var.name
  region                = local.region
  load_balancing_scheme = "EXTERNAL"
  health_checks         = var.create_health_check ? [google_compute_region_health_check.this[0].self_link] : []
  protocol              = "UNSPECIFIED"
  project               = var.project

  dynamic "backend" {
    for_each = var.backend_instance_groups
    content {
      group = backend.value
    }
  }

  # this section requires the google-beta provider as of 2022-04-13
  connection_tracking_policy {
    tracking_mode                                = var.connection_tracking_mode
    connection_persistence_on_unhealthy_backends = var.connection_persistence_on_unhealthy_backends
    idle_timeout_sec                             = var.idle_timeout_sec
  }
}

# Create `google_compute_region_backend_service` if require by `var.rules`
resource "google_compute_region_health_check" "this" {
  count = var.create_health_check && local.backend_service_needed ? 1 : 0

  name                = "${var.name}-${local.region}"
  project             = var.project
  region              = local.region
  check_interval_sec  = var.health_check_interval_sec
  healthy_threshold   = var.health_check_healthy_threshold
  timeout_sec         = var.health_check_timeout_sec
  unhealthy_threshold = var.health_check_unhealthy_threshold

  http_health_check {
    port         = var.health_check_http_port
    request_path = var.health_check_http_request_path
    host         = var.health_check_http_host
  }
}

