output vm_names {
  value = google_compute_instance.default.*.name
}

output vm_self_link {
  value = google_compute_instance.default.*.self_link
}

output instance_group {
  value = google_compute_instance_group.default.*.self_link
}

output nic0_public_ip {
  value = { for k, v in google_compute_instance.default : k => v.network_interface.0.access_config.0.nat_ip }
}
