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
  // FIXME allow_stopping_for_update = true
  tags = var.tags

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

  #  FIXME boot_disk {
  #     initialize_params {
  #       image = 
  #     }
  #   }
  disk {
    source_image = var.image
    type         = var.disk_type
    auto_delete  = true
    boot         = true
  }

  depends_on = [
    null_resource.dependency_getter
  ]
}

# resource "google_compute_region_instance_group" "this" {
#   count     = var.create_instance_group ? length(var.names) : 0
#   name      = "${element(var.names, count.index)}-${element(var.zones, count.index)}-ig"
#   zone      = element(var.zones, count.index)
#   instances = [google_compute_instance.vmseries[count.index].self_link]
#   named_port {
#     name = "http"
#     port = "80"
#   }
#   lifecycle {
#     create_before_destroy = true
#   }
# }


resource "google_compute_region_instance_group_manager" "this" {
  name = "${var.prefix}-igm"

  base_instance_name        = "${var.prefix}-fw"
  region                    = var.region
  distribution_policy_zones = var.zones

  version {
    instance_template = google_compute_instance_template.this.id
  }

  target_pools = [var.pool]
  target_size  = 1 // FIXME not for autoscaler

  named_port {
    name = "custom"
    port = 80
  }

  # auto_healing_policies {
  #   health_check      = google_compute_health_check.autohealing.id
  #   initial_delay_sec = 300
  # }
}
