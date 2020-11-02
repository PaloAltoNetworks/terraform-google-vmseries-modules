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
  count  = length(var.names)
  name   = "${element(var.names, count.index)}-nic0"
  region = var.region
}

# Permanent private address, not ephemeral, because firewalls keep it saved.
resource "google_compute_address" "private" {
  count        = length(var.names)
  address_type = "INTERNAL"
  name         = "${element(var.names, count.index)}-nic0-private"
  subnetwork   = var.subnetworks[0]
  region       = var.region
  # address      = try(each.value.nic.ip_address, null)
  # subnetwork   = each.value.nic.subnetwork
  # region       = data.google_compute_subnetwork.this[each.key].region
}

resource "google_compute_disk" "panorama_logs1" {
  count = length(var.names)
  name  = "${element(var.names, count.index)}-logs"
  zone  = element(var.zones, count.index)
  type  = "pd-standard"
  size  = "2000"
}

resource "google_compute_disk" "panorama_logs2" {
  count = length(var.names)
  name  = "${element(var.names, count.index)}-logs2"
  zone  = element(var.zones, count.index)
  type  = "pd-standard"
  size  = "2000"
}

resource "google_compute_instance" "this" {
  count                     = length(var.names)
  name                      = element(var.names, count.index)
  zone                      = element(var.zones, count.index)
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
      for_each = var.nic0_public_ip ? [""] : []
      content {
        nat_ip = google_compute_address.nic0[count.index].address
      }
    }
    network_ip = element(var.nic0_ip, count.index)
    subnetwork = var.subnetworks[0]
  }

  boot_disk {
    initialize_params {
      image = coalesce(var.image_uri, "${var.image_prefix_uri}${var.image_name}")
      type  = var.disk_type
    }
  }

  attached_disk {
    source = google_compute_disk.panorama_logs1[count.index].name
  }

  attached_disk {
    source = google_compute_disk.panorama_logs2[count.index].name
  }

  depends_on = [
    google_compute_image.this
  ]
}
