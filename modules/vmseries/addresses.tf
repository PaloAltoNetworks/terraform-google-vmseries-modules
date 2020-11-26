
# Using the default ephemeral IPs on a firewall is a bad idea, because GCE often changes them.
# While some users will just provide explicit static IP addresses (like "192.168.2.22"), we will accommodate 
# also the remaining users - those who'd like to have dynamic IP addresses.
#
# We use here google_compute_address to reserve a dynamically assigned IP address as a named entity.
# Such address will not change even if the virtual machine is stopped or removed.

locals {
  # Terraform for_each unfortunately requires a single-dimensional map, but we have
  # a two-dimensional input. We need two steps for conversion.
  #
  # First, flatten() ensures that this local value is a flat list of objects, rather
  # than a list of lists of objects.
  input_flat_interfaces = flatten([
    for instance_key, instance in var.instances : [
      for nic_key, nic in instance.network_interfaces : {
        instance_key = instance_key
        instance     = instance
        nic_key      = nic_key
        nic          = nic
      }
    ]
  ])

  # Convert flat list to a flat map. Make sure the keys are unique. This is used for for_each.
  input_interfaces = { for v in local.input_flat_interfaces : "${v.instance_key}-${v.nic_key}" => v }

  # The for_each will consume a flat map and produce a new flat map of dynamically-created resources.
  # As a final step, gather results back into a handy two-dimensional map.
  # Create a usable result - augument the input with our dynamically created resources.
  dyn_interfaces = { for instance_key, instance in var.instances :
    instance_key => {
      for nic_key, nic in instance.network_interfaces :
      nic_key => {
        subnetwork_cidr = data.google_compute_subnetwork.this["${instance_key}-${nic_key}"].ip_cidr_range
        subnetwork_gw   = cidrhost(data.google_compute_subnetwork.this["${instance_key}-${nic_key}"].ip_cidr_range, 1)
        network_ip      = google_compute_address.private["${instance_key}-${nic_key}"].address
        nat_ip = (
          # If we have been given an excplicit nat_ip, use it. Else, use our own named address.
          try(nic.nat_ip, null) != null ?
          nic.nat_ip
          :
          try(google_compute_address.public["${instance_key}-${nic_key}"].address, null)
        )
        public_ptr_domain_name = try(nic.public_ptr_domain_name, null)
      }
    }
  }
}

data "google_compute_subnetwork" "this" {
  for_each = local.input_interfaces

  self_link = each.value.nic.subnetwork
}

resource "google_compute_address" "private" {
  for_each = local.input_interfaces

  name = try(
    each.value.nic.address_name,
    "${each.value.instance.name}-nic${each.value.nic_key}",
  )
  address_type = "INTERNAL"
  address      = try(each.value.nic.ip_address, null)
  subnetwork   = each.value.nic.subnetwork
  region       = data.google_compute_subnetwork.this[each.key].region
}

resource "google_compute_address" "public" {
  for_each = { for k, v in local.input_interfaces : k => v if v.nic.public_nat && try(v.nic.nat_ip, null) == null }

  name = try(
    each.value.nic.public_address_name,
    "${each.value.instance.name}-nic${each.value.nic_key}-public",
  )
  address_type = "EXTERNAL"
  region       = data.google_compute_subnetwork.this[each.key].region
}
