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

locals {
  # flatten ensures that this local value is a flat list of objects, rather
  # than a list of lists of objects.
  flat_interfaces = flatten([
    for instance_key, instance in var.instances : [
      for nic_key, _ in instance.network_interfaces : {
        instance_key = instance_key
        instance     = instance
        nic_key      = nic_key
        nic = merge(
          {
            # all the defaults
            public_nat     = false,
            address_name   = "${instance.name}-nic${nic_key}",
            alias_ip_range = [],
          },
          instance.network_interfaces_base[nic_key],
          instance.network_interfaces[nic_key],
          instance.network_interfaces_custom[nic_key],
        )
      }
    ]
  ])
  # Convert list to a map. Make sure the keys are unique.
  interfaces = { for v in local.flat_interfaces : "${v.instance_key}-${v.nic_key}" => v }
}

data "google_compute_subnetwork" "this" {
  for_each = local.interfaces

  self_link = each.value.nic.subnetwork
}

// The google_compute_address reserves a dynamically assigned IP address and then names it.
// The unnamed (ephemeral) IP is a bad idea for a firewall, because it often changes unintentionally.
// This resource wouldn't be necessary if we only used statically assigned IP addresses.
resource "google_compute_address" "this" {
  for_each = local.interfaces

  name         = each.value.nic.address_name
  address_type = each.value.nic.public_nat ? "EXTERNAL" : "INTERNAL"
  address      = each.value.nic.public_nat ? null : try(each.value.nic.ip_address, null)
  subnetwork   = each.value.nic.public_nat ? null : each.value.nic.subnetwork
  region       = data.google_compute_subnetwork.this[each.key].region

  depends_on = [
    null_resource.dependency_getter
  ]
}
