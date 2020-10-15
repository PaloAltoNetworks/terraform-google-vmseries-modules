output instances {
  value = {
    for instance_key, instance in var.instances : instance_key => {
      name                      = instance.name
      zone                      = instance.zone
      network_interfaces_base   = []
      network_interfaces_custom = []
      network_interfaces = [for nic_key, _ in instance.network_interfaces : {
        subnetwork     = instance.network_interfaces[nic_key].subnetwork
        public_nat     = local.interfaces["${instance_key}-${nic_key}"].nic.public_nat
        alias_ip_range = local.interfaces["${instance_key}-${nic_key}"].nic.alias_ip_range
        nat_ip = try(
          local.interfaces["${instance_key}-${nic_key}"].nic.nat_ip,
          google_compute_address.this["${instance_key}-${nic_key}"].address,
          null
        )
        ip_address = try(
          local.interfaces["${instance_key}-${nic_key}"].nic.ip_address,
          local.interfaces["${instance_key}-${nic_key}"].nic.public_nat ? null : google_compute_address.this["${instance_key}-${nic_key}"].address,
          null
        )
      }]
    }
  }
}

output addresses {
  value = google_compute_address.this
}
