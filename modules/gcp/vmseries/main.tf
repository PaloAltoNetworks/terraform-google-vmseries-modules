resource "null_resource" "dependency_getter" {
  provisioner "local-exec" {
    command = "echo ${length(var.dependencies)}"
  }
}

resource "google_compute_instance" "vmseries" {
  for_each                  = var.firewalls
  name                      = each.value.name
  zone                      = each.value.zone
  machine_type              = var.machine_type
  min_cpu_platform          = var.cpu_platform
  tags                      = var.tags
  can_ip_forward            = true
  allow_stopping_for_update = true

  metadata = {
    mgmt-interface-swap                  = var.mgmt_interface_swap
    vmseries-bootstrap-gce-storagebucket = var.bootstrap_bucket
    serial-port-enable                   = true
    ssh-keys                             = var.ssh_key
  }

  service_account {
    email  = var.service_account
    scopes = var.scopes
  }

  network_interface {
    dynamic "access_config" {
      for_each = var.nic0_public_ip ? [""] : []
      content {}
    }
    network_ip = each.value.nic0_ip
    subnetwork = var.subnetworks[0]
  }

  network_interface {
    dynamic "access_config" {
      for_each = var.nic1_public_ip ? [""] : []
      content {}
    }
    network_ip = each.value.nic1_ip
    subnetwork = var.subnetworks[1]
  }

  network_interface {
    dynamic "access_config" {
      for_each = var.nic2_public_ip ? [""] : []
      content {}
    }
    network_ip = each.value.nic2_ip
    subnetwork = var.subnetworks[2]
  }

  boot_disk {
    initialize_params {
      image = var.image
      type  = var.disk_type
    }
  }

  depends_on = [
    null_resource.dependency_getter
  ]
}

// The Deployment Guide Jan 2020 recommends per-zone instance groups (instead of regional IGMs).
resource "google_compute_instance_group" "vmseries" {
  for_each  = var.firewalls
  name      = "${each.value.name}-${each.value.zone}-ig"
  zone      = each.value.zone
  instances = [google_compute_instance.vmseries[each.key].self_link]

  named_port {
    name = "http"
    port = "80"
  }

  lifecycle {
    create_before_destroy = true
  }
}

