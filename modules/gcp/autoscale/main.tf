terraform {
  required_providers {
    null   = { version = "~> 2.1" }
    random = { version = "~> 2.3" }
    google = { version = "~> 3.35" }
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
  min_cpu_platform = var.cpu_platform
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

resource "google_compute_region_instance_group_manager" "this" {
  # the '-igm-' is allegedly a magic string for Panorama
  name                      = "${var.prefix}-igm-${var.region}"
  base_instance_name        = "${var.prefix}-fw"
  region                    = var.region
  distribution_policy_zones = var.zones

  version {
    instance_template = google_compute_instance_template.this.id
  }

  target_pools = [var.pool]

  named_port {
    name = "custom"
    port = 80
  }

  # auto_healing_policies {
  #   health_check      = google_compute_health_check.autohealing.id
  #   initial_delay_sec = 300
  # }
}

resource "random_id" "autoscaler" {
  keepers = {
    # Re-randomize on igm change. It forcibly recreates all users of this random_id.
    google_compute_region_instance_group_manager = google_compute_region_instance_group_manager.this.id
  }
  byte_length = 3
}

resource "google_compute_region_autoscaler" "this" {
  name   = "${var.prefix}-${random_id.autoscaler.hex}-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.this.id

  autoscaling_policy {
    max_replicas = 1
    min_replicas = 1
    # FIXME
    # Given that it takes 7 minutes for a PA-VM to become functional, we need a cool down time
    # period of 10 minutes (600 seconds) for a new autoscale event to kick in.
    cooldown_period = 30

    # cpu_utilization { target = 0.7 }

    metric {
      name   = var.autoscaler_metric_name
      type   = var.autoscaler_metric_type
      target = var.autoscaler_metric_target
    }

  }
}
