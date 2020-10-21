terraform {
  required_providers {
    null   = { version = "~> 2.1" }
    google = { version = "~> 3.30" }
  }
}

resource "null_resource" "dependency_getter" {
  provisioner "local-exec" {
    command = "echo ${length(var.dependencies)}"
  }
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
  can_ip_forward            = true
  allow_stopping_for_update = true

  metadata = merge({
    mgmt-interface-swap                  = "enable"
    vmseries-bootstrap-gce-storagebucket = var.bootstrap_bucket
    serial-port-enable                   = true
    ssh-keys                             = var.ssh_key
  }, var.metadata)

  service_account {
    email  = var.service_account
    scopes = var.scopes
  }

  dynamic "network_interface" {
    for_each = { for k, v in each.value.network_interfaces : k => merge(
      try(each.value.network_interfaces_base[k], {}),
      each.value.network_interfaces[k],
      try(each.value.network_interfaces_custom[k], {}),
    ) }

    content {
      subnetwork = network_interface.value.subnetwork
      network_ip = try(network_interface.value.ip_address, null)

      dynamic "access_config" {
        # the "access_config", if present, creates a public IP address
        for_each = try(network_interface.value.public_nat, false) ? ["one"] : []
        content {
          nat_ip                 = try(network_interface.value.nat_ip, null)
          public_ptr_domain_name = try(network_interface.value.public_ptr_domain_name, null)
        }
      }

      dynamic "alias_ip_range" {
        for_each = try(network_interface.value.alias_ip_range, [])
        content {
          ip_cidr_range         = alias_ip_range.value.ip_cidr_range
          subnetwork_range_name = try(alias_ip_range.value.subnetwork_range_name, null)
        }
      }
    }
  }

  # TODO: var.linux_fake  -> 0.0/0 route for both nic0 and nic1 -> ip vrf add nic1 ; ip ro add 0.0.0.0/0

  boot_disk {
    initialize_params {
      image = coalesce(var.image_uri, "${var.image_prefix_uri}${var.image_name}")
      type  = var.disk_type
    }
  }

  depends_on = [
    null_resource.dependency_getter
  ]
}

// The Deployment Guide Jan 2020 recommends per-zone instance groups (instead of regional IGMs).
resource "google_compute_instance_group" "this" {
  for_each = var.create_instance_group ? var.instances : {}

  name      = "${each.value.name}-${each.value.zone}-ig"
  zone      = each.value.zone
  project   = var.project
  instances = [google_compute_instance.this[each.key].self_link]

  dynamic "named_port" {
    for_each = var.named_ports
    content {
      name = named_port.value.name
      port = named_port.value.port
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

