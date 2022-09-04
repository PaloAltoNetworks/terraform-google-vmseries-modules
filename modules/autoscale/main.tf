# --------------------------------------------------------------------------------------------------------------------------------------------
# Create Pub/Sub for Panorama Plugin & create instance template
# --------------------------------------------------------------------------------------------------------------------------------------------

resource "google_pubsub_topic" "main" {
  count = var.create_pubsub_topic ? 1 : 0
  name  = "${var.name}-mig-topic"
}

resource "google_pubsub_subscription" "main" {
  count = var.create_pubsub_topic ? 1 : 0
  name  = "${var.name}-mig-subscription"
  topic = google_pubsub_topic.main[0].id
}

resource "google_pubsub_subscription_iam_member" "main" {
  count        = var.create_pubsub_topic ? 1 : 0
  subscription = google_pubsub_subscription.main[0].id
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${coalesce(var.service_account_email, data.google_compute_default_service_account.main.email)}"
}

data "google_compute_default_service_account" "main" {}

resource "google_compute_instance_template" "main" {
  name_prefix      = "${var.name}-template"
  machine_type     = var.machine_type
  min_cpu_platform = var.min_cpu_platform
  can_ip_forward   = true
  tags             = var.tags
  metadata         = var.metadata

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


# --------------------------------------------------------------------------------------------------------------------------------------------
# Zone-based managed instance group creation 
# --------------------------------------------------------------------------------------------------------------------------------------------

resource "google_compute_instance_group_manager" "zonal" {
  for_each           = var.use_regional_mig ? {} : var.zones
  name               = "${var.name}-mig-${each.value}"
  target_pools       = var.target_pool_self_links
  base_instance_name = var.name
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
  for_each = var.use_regional_mig ? {} : var.zones
  name     = "${var.name}-autoscaler-${each.value}"
  target   = try(google_compute_instance_group_manager.zonal[each.key].id, "")
  zone     = each.value

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

# --------------------------------------------------------------------------------------------------------------------------------------------
# Regional managed instance group creation
# --------------------------------------------------------------------------------------------------------------------------------------------

data "google_compute_zones" "main" {
  region = var.region
}

resource "google_compute_region_instance_group_manager" "regional" {
  count              = var.use_regional_mig ? 1 : 0
  name               = "${var.name}-mig"
  target_pools       = var.target_pool_self_links
  base_instance_name = var.name
  region             = var.region

  version {
    instance_template = google_compute_instance_template.main.id
  }

  update_policy {
    type            = var.update_policy_type
    max_surge_fixed = length(data.google_compute_zones.main)
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
  count  = var.use_regional_mig ? 1 : 0
  name   = "${var.name}-autoscaler"
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