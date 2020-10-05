resource "google_compute_instance" "default" {
  for_each                  = var.instances
  name                      = each.value.name
  zone                      = each.value.zone
  machine_type              = var.machine_type
  can_ip_forward            = true
  allow_stopping_for_update = true
  metadata_startup_script   = var.startup_script

  metadata = {
    serial-port-enable = true
    ssh-keys           = var.ssh_key
  }

  network_interface {
    subnetwork = each.value.subnetwork

    access_config {
      nat_ip = google_compute_address.this[each.key].address
    }
  }

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  service_account {
    scopes = var.scopes
  }
}

resource "google_compute_address" "this" {
  for_each = var.instances
  name     = each.value.name
}

resource "google_compute_instance_group" "default" {
  for_each  = var.create_instance_group ? var.instances : {}
  name      = "${each.value.name}-${each.value.zone}-ig"
  zone      = each.value.zone
  instances = [google_compute_instance.default[each.key].self_link]

  named_port {
    name = "http"
    port = "80"
  }

  lifecycle {
    create_before_destroy = true
  }
}
