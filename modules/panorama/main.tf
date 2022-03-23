data "google_compute_image" "this" {
  count = var.custom_image != null ? 0 : 1

  family  = var.image_family
  project = var.image_project
}

# Permanent private address, not ephemeral, because the managed firewalls keep it saved.
resource "google_compute_address" "private" {
  address_type = "INTERNAL"
  region       = var.region
  name         = "${var.panorama_name}-nic0-private"
  subnetwork   = var.subnet
  address      = try(var.private_static_ip, null)
}

# Permanent public address, not ephemeral.
resource "google_compute_address" "public" {
  count = var.attach_public_ip ? 1 : 0

  region  = var.region
  name    = "${var.panorama_name}-nic0-public"
  address = try(var.public_static_ip, null)
}

resource "google_compute_disk" "panorama_logs1" {
  name = "${var.panorama_name}-logs1"
  zone = var.zone
  type = var.log_disk_type
  size = var.log_disk_size
}

resource "google_compute_disk" "panorama_logs2" {
  name = "${var.panorama_name}-logs2"
  zone = var.zone
  type = var.log_disk_type
  size = var.log_disk_size
}

resource "google_compute_instance" "this" {
  name             = var.panorama_name
  zone             = var.zone
  machine_type     = var.machine_type
  min_cpu_platform = var.min_cpu_platform
  labels           = var.labels
  tags             = var.tags
  project          = var.project
  # resource_policies         = var.resource_policies
  can_ip_forward            = false
  allow_stopping_for_update = true

  metadata = merge({
    serial-port-enable = true
    ssh-keys           = var.ssh_key
  }, var.metadata)

  # service_account {
  #   email  = var.service_account
  #   scopes = var.scopes
  # }

  # network_interface {
  #   dynamic "access_config" {
  #     for_each = var.public_nat ? ["one"] : []
  #     content {
  #       nat_ip = try(google_compute_address.public[each.key].address, null)
  #     }
  #   }
  #   network_ip = google_compute_address.private[each.key].address
  #   subnetwork = each.value.subnetwork
  # }

  network_interface {
    network_ip = google_compute_address.private.address
    subnetwork = var.subnet
    access_config {
      nat_ip = var.attach_public_ip ? google_compute_address.public[0].address : null

    }
  }

  boot_disk {
    initialize_params {
      image = coalesce(var.custom_image, data.google_compute_image.this[0].id)
      size  = var.disk_size
      type  = var.disk_type
    }
  }

  attached_disk {
    source = google_compute_disk.panorama_logs1.name
  }

  attached_disk {
    source = google_compute_disk.panorama_logs2.name
  }
}
