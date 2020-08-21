# --- create bucket and upload panorama source image file ---
resource "google_storage_bucket" "panorama-bucket" {
  name                     = var.panorama_bucket_name
  default_event_based_hold = false
  location                 = var.region
}

resource "google_storage_bucket_object" "panorama-bucket-image" {
  name       = var.panorama_image_file_name
  source     = "${var.panorama_image_file_path}/${var.panorama_image_file_name}"
  bucket     = var.panorama_bucket_name
  depends_on = [ google_storage_bucket.panorama-bucket ]
}

# --- create panorama VM image ---
resource "google_compute_image" "panorama-image" {
  name = var.image
  raw_disk {
    container_type = "TAR"
    source         = "${var.storage_uri}/${var.panorama_bucket_name}/${var.panorama_image_file_name}?authuser=0"
  }
  timeouts {
    create = var.image_create_timeout
  }
  depends_on = [ google_storage_bucket_object.panorama-bucket-image ]

}

# --- create network interfaces for panorama ---
resource "google_compute_address" "nic0" {
  count  = length(var.names)
  name   = "${element(var.names, count.index)}-nic0"
  region = var.region
}

# --- create additional disk for Panorama ---
resource "google_compute_disk" "panorama-log-disk" {
  count = length(var.names)
  name  = "${element(var.names, count.index)}-log-disk"
  zone  = element(var.zones, count.index)
  type  = "pd-standard"
  size  = "2000"
}

resource "google_compute_disk" "panorama-log-disk2" {
  count = length(var.names)
  name  = "${element(var.names, count.index)}-log-disk2"
  zone  = element(var.zones, count.index)
  type  = "pd-standard"
  size  = "2000"
}



# --- create panorama instances ---
resource "google_compute_instance" "panorama" {
  count                     = length(var.names)
  name                      = element(var.names, count.index)
  machine_type              = var.machine_type
  zone                      = element(var.zones, count.index)
  min_cpu_platform          = var.cpu_platform
  can_ip_forward            = true
  allow_stopping_for_update = true
  tags                      = var.tags

  metadata = {
    # panorama-bootstrap-gce-storagebucket = var.bootstrap_bucket
    serial-port-enable = true
    ssh-keys           = var.ssh_key
  }

  service_account {
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
      image = var.image
      type  = var.disk_type
    }
  }

  attached_disk {
      source = "${element(var.names, count.index)}-log-disk"
  }

  attached_disk {
      source = "${element(var.names, count.index)}-log-disk2"
  }

  depends_on = [
      google_compute_image.panorama-image
  ]
}
