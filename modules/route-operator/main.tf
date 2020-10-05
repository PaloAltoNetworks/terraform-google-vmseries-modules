resource "google_compute_instance" "this" {
  for_each                  = var.instances
  name                      = each.value.name
  zone                      = each.value.zone
  machine_type              = var.machine_type
  allow_stopping_for_update = true

  metadata = {
    serial-port-enable = true
    ssh-keys           = "${var.ssh_user}:${var.ssh_public_key}"
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
    email  = google_service_account.this.email
    scopes = var.scopes
  }

  metadata_startup_script = <<-END_SCRIPT
    #!/bin/bash
    #
    # The runtime logs are in the /var/log/syslog on Ubuntu (for any metadata script)

    while true; do
      sleep 10
      cd /home/${var.ssh_user}
      cat cert.pem interm.pem > bundle.pem
      chmod a+x ro_api_d
      ./ro_api_d
    done
    END_SCRIPT
}

# Kill the application so it doesn't keep the binary file locked.
resource "null_resource" "pkill" {
  for_each = var.instances

  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = var.ssh_private_key
    host        = google_compute_instance.this[each.key].network_interface[0].access_config[0].nat_ip
  }

  provisioner "remote-exec" {
    inline = [
      "rm -f /home/${var.ssh_user}/ro_api_d",
      "sudo pkill -f 'ro_api_[d]' || true",
    ]
  }

  triggers = {
    # TODO serialize for_each instance updates somehow
    file1 = filesha1(var.https_key_pem_file)
    file2 = filesha1(var.https_cert_pem_file)
    file3 = filesha1(var.https_interm_pem_file)
    file4 = yamlencode(local.ro_api_config)
    file5 = filesha1("${path.module}/ro_api_d")
  }
}

resource "null_resource" "files" {
  for_each = var.instances
  triggers = {
    trigger = null_resource.pkill[each.key].id
  }

  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = var.ssh_private_key
    host        = google_compute_instance.this[each.key].network_interface[0].access_config[0].nat_ip
  }

  provisioner "file" {
    source      = var.https_key_pem_file
    destination = "key.pem"
  }

  provisioner "file" {
    source      = var.https_cert_pem_file
    destination = "cert.pem"
  }

  provisioner "file" {
    source      = var.https_interm_pem_file
    destination = "interm.pem"
  }

  provisioner "file" {
    content     = yamlencode(local.ro_api_config)
    destination = "ro_api_config.yaml"
  }

  provisioner "file" {
    source      = "${path.module}/ro_api_d"
    destination = "ro_api_d"
  }
  // That binary for the application needs to be last, so don't append any new "file" below.
}

locals {
  # just use var.routes, but insert into it also var.http_basic_auth
  ro_api_config = merge(var.routes, {
    "config" = {
      "http_basic_auth" = var.http_basic_auth
    }
  })
}

resource "google_compute_address" "this" {
  for_each = var.instances
  name     = each.value.name
}

resource "google_compute_instance_group" "this" {
  for_each  = var.instances
  name      = "${each.value.name}-${each.value.zone}-ig"
  zone      = each.value.zone
  instances = [google_compute_instance.this[each.key].self_link]

  named_port {
    name = "http"
    port = "3000"
  }

  named_port {
    name = "https"
    port = "8443"
  }
}

data "google_compute_subnetwork" "this" {
  for_each = var.instances
  name     = each.value.subnetwork
}

resource "google_compute_firewall" "ping_access" {
  for_each      = var.instances
  name          = "${each.value.name}-ping"
  network       = data.google_compute_subnetwork.this[each.key].network
  source_ranges = [google_compute_instance.this[each.key].network_interface.0.network_ip]

  allow {
    protocol = "icmp"
  }

}

resource "google_compute_firewall" "http_self_access" {
  for_each      = var.instances
  name          = "${each.value.name}-http"
  network       = data.google_compute_subnetwork.this[each.key].network
  source_ranges = [data.google_compute_subnetwork.this[each.key].ip_cidr_range]

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "3000", "8443"]
  }
}
