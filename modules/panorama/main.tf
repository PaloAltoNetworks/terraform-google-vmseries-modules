data "google_compute_image" "this" {
  count = var.custom_image != null ? 0 : 1

  project = "paloaltonetworksgcp-public"
  name    = var.panorama_version
}

# Permanent private address, not ephemeral, because the managed firewalls keep it saved.
resource "google_compute_address" "private" {
  address_type = "INTERNAL"
  region       = var.region
  name         = "${var.name}-private"
  subnetwork   = var.subnet
  address      = try(var.private_static_ip, null)
}

# Permanent public address, not ephemeral.
resource "google_compute_address" "public" {
  count = var.attach_public_ip ? 1 : 0

  region  = var.region
  name    = "${var.name}-public"
  address = try(var.public_static_ip, null)
}

resource "google_compute_disk" "this" {
  for_each = { for k, v in var.log_disks : k => v }

  name = each.value.name
  zone = var.zone
  type = each.value.type
  size = each.value.size
}

resource "google_compute_attached_disk" "default" {
  for_each = { for k, v in var.log_disks : k => v }

  disk     = google_compute_disk.this[each.key].id
  instance = google_compute_instance.this.id
}

resource "google_compute_instance" "this" {
  name                      = var.name
  zone                      = var.zone
  machine_type              = var.machine_type
  min_cpu_platform          = var.min_cpu_platform
  labels                    = var.labels
  tags                      = var.tags
  project                   = var.project
  can_ip_forward            = false
  allow_stopping_for_update = true

  metadata = merge({
    serial-port-enable = true
    ssh-keys           = var.ssh_keys
  }, var.metadata)

  network_interface {

    dynamic "access_config" {
      for_each = var.attach_public_ip ? [""] : []
      content {
        nat_ip = google_compute_address.public[0].address
      }
    }

    network_ip = google_compute_address.private.address
    subnetwork = var.subnet
  }

  boot_disk {
    initialize_params {
      image = coalesce(var.custom_image, data.google_compute_image.this[0].id)
      size  = var.disk_size
      type  = var.disk_type
    }
  }
}
