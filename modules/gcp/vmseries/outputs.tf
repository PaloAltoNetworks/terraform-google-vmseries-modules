output vm_names {
  value = [for v in google_compute_instance.vmseries : v.name]
}

output vm_self_link {
  value = [for v in google_compute_instance.vmseries : v.self_link]
}

output instance_group {
  value = [for v in google_compute_instance_group.vmseries : v.self_link]
}

output nic0_public_ip {
  value = var.nic0_public_ip ? [for v in google_compute_instance.vmseries : v.network_interface.0.access_config.0.nat_ip] : []
}

output nic1_public_ip {
  value = var.nic1_public_ip ? [for v in google_compute_instance.vmseries : v.network_interface.1.access_config.0.nat_ip] : []
}

output nic2_public_ip {
  value = var.nic2_public_ip ? [for v in google_compute_instance.vmseries : v.network_interface.2.access_config.0.nat_ip] : []
}

