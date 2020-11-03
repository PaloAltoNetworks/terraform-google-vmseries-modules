terraform {
  required_providers {
    google = {
      version = "~> 3.30"
    }
  }
}

# Optional bucket, when we upload panorama os from a custom *.tar.gz file.
resource "google_storage_bucket" "this" {
  count = var.panorama_image_file_name != "" ? 1 : 0

  name                     = var.panorama_bucket_name
  default_event_based_hold = false
  location                 = var.region
}

resource "google_storage_bucket_object" "this" {
  count = var.panorama_image_file_name != "" ? 1 : 0

  name   = var.panorama_image_file_name
  source = "${var.panorama_image_file_path}/${var.panorama_image_file_name}"
  bucket = google_storage_bucket.this[0].name
}

resource "google_compute_image" "this" {
  count = var.panorama_image_file_name != "" ? 1 : 0

  name = var.image_uri

  raw_disk {
    container_type = "TAR"
    source         = "${var.storage_uri}/${var.panorama_bucket_name}/${var.panorama_image_file_name}?authuser=0"
  }

  timeouts {
    create = var.image_create_timeout
  }
  depends_on = [google_storage_bucket_object.this]
}

# Permanent public address, not ephemeral.
resource "google_compute_address" "nic0" {
  for_each = var.instances

  name    = "${each.value.name}-nic0"
  address = try(each.value.nat_ip, null)
  region  = var.region
}

# Permanent private address, not ephemeral, because firewalls keep it saved.
resource "google_compute_address" "private" {
  for_each = var.instances

  address_type = "INTERNAL"
  name         = "${each.value.name}-nic0-private"
  subnetwork   = each.value.subnetwork
  region       = var.region
  address      = try(each.value.network_ip, null)
  # TODO region       = data.google_compute_subnetwork.this[each.key].region
}

resource "google_compute_disk" "panorama_logs1" {
  for_each = var.instances

  name = "${each.value.name}-logs1"
  zone = each.value.zone
  type = var.log_disk_type
  size = var.log_disk_size
}

resource "google_compute_disk" "panorama_logs2" {
  for_each = var.instances

  name = "${each.value.name}-logs2"
  zone = each.value.zone
  type = var.log_disk_type
  size = var.log_disk_size
}

resource "google_compute_instance" "this" {
  for_each = var.instances

  name                      = each.value.name
  zone                      = each.value.zone
  machine_type              = var.machine_type
  min_cpu_platform          = var.min_cpu_platform
  labels                    = var.labels
  tags                      = var.tags
  metadata_startup_script   = var.metadata_startup_script
  project                   = var.project
  resource_policies         = var.resource_policies
  can_ip_forward            = false
  allow_stopping_for_update = true

  metadata = merge({
    serial-port-enable = true
    ssh-keys           = var.ssh_key
  }, var.metadata)

  service_account {
    email  = var.service_account
    scopes = var.scopes
  }

  network_interface {
    dynamic "access_config" {
      for_each = var.nic0_public_ip ? ["one"] : []
      content {
        nat_ip = try(google_compute_address.nic0[each.key].nat_ip, null)
      }
    }
    network_ip = try(each.value.network_ip, null)
    subnetwork = each.value.subnetwork
  }

  boot_disk {
    initialize_params {
      image = coalesce(var.image_uri, "${var.image_prefix_uri}${var.image_name}")
      type  = var.disk_type
    }
  }

  attached_disk {
    source = google_compute_disk.panorama_logs1[each.key].name
  }

  attached_disk {
    source = google_compute_disk.panorama_logs2[each.key].name
  }

  depends_on = [
    google_compute_image.this
  ]
}
