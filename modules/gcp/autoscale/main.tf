terraform {
  required_providers {
    null = {
      version = "~> 2.1"
    }
    random = {
      version = "~> 2.3"
    }
    google = {
      version = "~> 3.35"
    }
  }
}

resource "null_resource" "dependency_getter" {
  provisioner "local-exec" {
    command = "echo ${length(var.dependencies)}"
  }
}

resource "google_compute_instance_template" "this" {
  name_prefix      = "${var.prefix}-template"
  machine_type     = var.machine_type
  min_cpu_platform = var.min_cpu_platform
  can_ip_forward   = true
  tags             = var.tags

  metadata = {
    mgmt-interface-swap                  = var.mgmt_interface_swap
    vmseries-bootstrap-gce-storagebucket = var.bootstrap_bucket
    serial-port-enable                   = true
    ssh-keys                             = var.ssh_key
  }

  service_account {
    scopes = var.scopes
    email  = var.service_account
  }

  network_interface {

    dynamic "access_config" {
      for_each = var.nic0_public_ip ? [""] : []
      content {}
    }
    network_ip = var.nic0_ip[0]
    subnetwork = var.subnetworks[0]
  }

  network_interface {
    dynamic "access_config" {
      for_each = var.nic1_public_ip ? [""] : []
      content {}
    }
    network_ip = var.nic1_ip[0]
    subnetwork = var.subnetworks[1]
  }

  network_interface {
    dynamic "access_config" {
      for_each = var.nic2_public_ip ? [""] : []
      content {}
    }
    network_ip = var.nic2_ip[0]
    subnetwork = var.subnetworks[2]
  }

  disk {
    source_image = var.image
    disk_type    = var.disk_type
    auto_delete  = false # FIXME true # needed for de-registration
    boot         = true
  }

  depends_on = [
    null_resource.dependency_getter
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_group_manager" "this" {
  for_each           = var.zones
  base_instance_name = "${var.prefix}-fw"
  name               = "${var.prefix}-igm-${each.value}"
  zone               = each.value
  target_pools       = [var.pool]
  version {
    instance_template = google_compute_instance_template.this.id
  }
  named_port {
    name = "custom"
    port = 80
  }
}

resource "random_id" "autoscaler" {
  for_each = var.zones
  keepers = {
    # Re-randomize on igm change. It forcibly recreates all users of this random_id.
    google_compute_instance_group_manager = google_compute_instance_group_manager.this[each.key].id
  }
  byte_length = 3
}

resource "google_compute_autoscaler" "this" {
  for_each = var.zones
  name     = "${var.prefix}-${random_id.autoscaler[each.key].hex}-as-${each.value}"
  target   = google_compute_instance_group_manager.this[each.key].id
  zone     = each.value

  autoscaling_policy {
    max_replicas    = var.max_replicas_per_zone
    min_replicas    = var.min_replicas_per_zone
    cooldown_period = var.cooldown_period

    # cpu_utilization { target = 0.7 }

    metric {
      name   = var.autoscaler_metric_name
      type   = var.autoscaler_metric_type
      target = var.autoscaler_metric_target
    }

  }
}

#---------------------------------------------------------------------------------
# Pub-Sub is intended to be used by various cloud applications to register
# new ip/port that would be consumed by Panorama and automatically onboarded.

resource "google_pubsub_topic" "this" {
  name = "${var.deployment_name}-${var.project_id}-panorama-apps-deployment"
}


resource "google_pubsub_subscription" "this" {
  name  = "${var.deployment_name}-${var.project_id}-panorama-plugin-subscription"
  topic = google_pubsub_topic.this.id
}
