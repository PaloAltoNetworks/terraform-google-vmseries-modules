locals {
  interfaces = flatten([
    for fw, fw_info in var.firewalls : [
      for int_key, int_data in fw_info.interfaces : {
        name       = "${var.prefix}-${fw_info.name}-${var.environment}-${var.region}${fw_info.zone}-${int_key}"
        subnetwork = int_data.subnetwork
        ip_address = lookup(int_data, "ip_address", null)
        zone       = fw_info.zone
      }
    ]
  ])
  gcp_fw = { for int in values(var.firewalls)[0]["interfaces"] : int.subnetwork => {
    disabled      = lookup(int, "disabled", false)
    source_ranges = lookup(int, "source_ranges", ["0.0.0.0/0"])
    priority      = lookup(int, "priority", var.default_fw_priority)
    protocol      = lookup(int, "protocol", var.default_fw_protocol)
    direction     = lookup(int, "direction", "INGRESS")
    allow = lookup(int, "allow", {
      rule1 = {
        protocol = "all"
        ports    = null
      }
    })
    deny = lookup(int, "deny", [])
    }
    if lookup(values(var.firewalls)[0], "fw_build", false) != false ? true : false
  }
}

resource "null_resource" "dependency_getter" {
  provisioner "local-exec" {
    command = "echo ${length(var.dependencies)}"
  }
}

resource "google_compute_address" "this" {
  for_each = { for interface in local.interfaces :
  interface.name => interface }
  name         = each.key
  address_type = "INTERNAL"
  address      = each.value.ip_address
  region       = var.region
  subnetwork   = var.subnetworks[each.value.subnetwork].self_link
}

##TODO Adding support for GCP firewall rules that are used in conjunction with VM-Series

//resource "google_compute_firewall" "this" {
//  for_each = local.gcp_fw
//  name     = "${split("networks/", var.subnetworks[each.key].network)[1]}-paloalto-fw"
//  network  = var.subnetworks[each.key].network
//  //  allow {
//  //    protocol = each.value.protocol
//  //  }
//  dynamic "allow" {
//    for_each = each.value.allow
//    content {
//      protocol = allow.value.protocol
//      ports    = lookup(allow.value, "ports", null)
//    }
//  }
//  dynamic "deny" {
//    for_each = lookup(each.value, "allow", []) != [] ? lookup(each.value, "deny", []) : []
//    content {
//      protocol = deny.value.protocol
//      ports    = lookup(deny.value, "ports", null)
//    }
//  }
//  priority      = each.value.priority
//  direction     = each.value.direction
//  target_tags   = var.tags
//  source_ranges = each.value.source_ranges
//  disabled      = each.value.disabled
//}

resource "google_compute_instance" "vmseries" {
  for_each                  = var.firewalls
  name                      = "${var.prefix}-${each.value.name}--${var.environment}-${var.region}${each.value.zone}"
  zone                      = "${var.region}-${each.value.zone}"
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

  dynamic "network_interface" {
    for_each = each.value.interfaces
    content {
      dynamic "access_config" {
        for_each = lookup(network_interface.value, "access_config", [])
        content {
        }
      }
      network_ip = google_compute_address.this["${var.prefix}-${each.value.name}-${var.environment}-${var.region}${each.value.zone}-${network_interface.key}"].address
      subnetwork = var.subnetworks[network_interface.value.subnetwork].self_link
    }
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
  name      = "${var.prefix}-${each.value.name}--${var.environment}-${var.region}${each.value.zone}-ig"
  zone      = "${var.region}-${each.value.zone}"
  instances = [google_compute_instance.vmseries[each.key].self_link]

  named_port {
    name = "http"
    port = "80"
  }

    lifecycle {
      create_before_destroy = true
    }
  }

