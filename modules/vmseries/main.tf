resource "null_resource" "dependency_getter" {
  provisioner "local-exec" {
    command = "echo ${length(var.dependencies)}"
  }
}

resource "google_compute_instance" "this" {
  for_each                  = var.instances
  name                      = each.value.name
  zone                      = each.value.zone
  machine_type              = var.machine_type
  min_cpu_platform          = var.min_cpu_platform
  tags                      = var.tags
  can_ip_forward            = true
  allow_stopping_for_update = true

  metadata = {
    mgmt-interface-swap                  = "enable"
    vmseries-bootstrap-gce-storagebucket = var.bootstrap_bucket
    serial-port-enable                   = true
    ssh-keys                             = var.ssh_key
  }

  service_account {
    email  = var.service_account
    scopes = var.scopes
  }

  dynamic "network_interface" {
    for_each = each.value.network_interfaces

    content {
      dynamic "access_config" {
        # the "access_config", if present, creates a public IP address
        for_each = try(network_interface.value.public_ip, false) ? ["one"] : []
        content {}
      }

      network_ip = try(network_interface.value.ip_address, null)
      subnetwork = network_interface.value.subnetwork
    }
  }

  # TODO: var.linux_fake  -> 0.0/0 route for both nic0 and nic1 -> ip vrf add nic1 ; ip ro add 0.0.0.0/0

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
resource "google_compute_instance_group" "this" {
  for_each  = var.instances
  name      = "${each.value.name}-${each.value.zone}-ig"
  zone      = each.value.zone
  instances = [google_compute_instance.this[each.key].self_link]

  named_port {
    name = "http"
    port = "80"
  }

  lifecycle {
    create_before_destroy = true
  }
}

