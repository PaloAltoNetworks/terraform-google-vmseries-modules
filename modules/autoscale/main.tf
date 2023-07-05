data "google_compute_default_service_account" "main" {}

# Instance template
resource "google_compute_instance_template" "main" {
  name_prefix      = var.name
  machine_type     = var.machine_type
  min_cpu_platform = var.min_cpu_platform
  tags             = var.tags
  metadata         = var.metadata
  can_ip_forward   = true

  service_account {
    scopes = var.scopes
    email  = var.service_account_email
  }

  dynamic "network_interface" {
    for_each = var.network_interfaces

    content {
      subnetwork = network_interface.value.subnetwork

      dynamic "access_config" {
        for_each = try(network_interface.value.create_public_ip, false) ? ["one"] : []
        content {}
      }
    }
  }

  disk {
    source_image = var.image
    disk_type    = var.disk_type
    auto_delete  = true
    boot         = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Zonal managed instance group and autoscaler
resource "google_compute_instance_group_manager" "zonal" {
  for_each = var.regional_mig ? {} : var.zones

  name               = "${var.name}-${each.value}"
  base_instance_name = var.name
  target_pools       = var.target_pools
  zone               = each.value

  version {
    instance_template = google_compute_instance_template.main.id
  }

  lifecycle {
    ignore_changes = [
      version[0].name,
      version[1].name,
    ]
  }

  update_policy {
    type            = var.update_policy_type
    max_surge_fixed = 1
    minimal_action  = "REPLACE"
  }

  dynamic "named_port" {
    for_each = var.named_ports
    content {
      name = named_port.value.name
      port = named_port.value.port
    }
  }
}

resource "google_compute_autoscaler" "zonal" {
  for_each = var.regional_mig ? {} : var.zones

  name   = "${var.name}-${each.value}"
  target = google_compute_instance_group_manager.zonal[each.key].id
  zone   = each.value

  autoscaling_policy {
    min_replicas    = var.min_vmseries_replicas
    max_replicas    = var.max_vmseries_replicas
    cooldown_period = var.cooldown_period

    dynamic "metric" {
      for_each = var.autoscaler_metrics
      content {
        name   = metric.key
        type   = try(metric.value.type, "GAUGE")
        target = metric.value.target
      }
    }

    scale_in_control {
      time_window_sec = var.scale_in_control_time_window_sec
      max_scaled_in_replicas {
        fixed = var.scale_in_control_replicas_fixed
      }
    }
  }
}

# Regional managed instance group and autoscaler
data "google_compute_zones" "main" {
  count = var.regional_mig ? 1 : 0

  region = var.region
}

resource "google_compute_region_instance_group_manager" "regional" {
  count = var.regional_mig ? 1 : 0

  name               = var.name
  base_instance_name = var.name
  target_pools       = var.target_pools
  region             = var.region

  version {
    instance_template = google_compute_instance_template.main.id
  }

  update_policy {
    type            = var.update_policy_type
    max_surge_fixed = length(data.google_compute_zones.main[0])
    minimal_action  = "REPLACE"
  }

  dynamic "named_port" {
    for_each = var.named_ports
    content {
      name = named_port.value.name
      port = named_port.value.port
    }
  }
}

resource "google_compute_region_autoscaler" "regional" {
  count = var.regional_mig ? 1 : 0

  name   = var.name
  target = google_compute_region_instance_group_manager.regional[0].id
  region = var.region

  autoscaling_policy {
    min_replicas    = var.min_vmseries_replicas
    max_replicas    = var.max_vmseries_replicas
    cooldown_period = var.cooldown_period

    dynamic "metric" {
      for_each = var.autoscaler_metrics
      content {
        name   = metric.key
        type   = try(metric.value.type, "GAUGE")
        target = metric.value.target
      }
    }

    scale_in_control {
      time_window_sec = var.scale_in_control_time_window_sec
      max_scaled_in_replicas {
        fixed = var.scale_in_control_replicas_fixed
      }
    }
  }
}

# Pub/Sub for Panorama Plugin
resource "google_pubsub_topic" "main" {
  count = var.create_pubsub_topic ? 1 : 0

  name = "${var.name}-mig"
}

resource "google_pubsub_subscription" "main" {
  count = var.create_pubsub_topic ? 1 : 0

  name  = "${var.name}-mig"
  topic = google_pubsub_topic.main[0].id
}

resource "google_pubsub_subscription_iam_member" "main" {
  count = var.create_pubsub_topic ? 1 : 0

  subscription = google_pubsub_subscription.main[0].id
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${coalesce(var.service_account_email, data.google_compute_default_service_account.main.email)}"
}