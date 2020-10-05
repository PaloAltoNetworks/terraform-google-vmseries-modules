output vm_names {
  value = { for k, v in google_compute_instance.this : k => v.name }
}

output vm_self_link {
  value = { for k, v in google_compute_instance.this : k => v.self_link }
}

output instance_group {
  value = { for k, v in google_compute_instance_group.this : k => v.self_link }
}

output vm_self_link_list {
  value = sort([for k, v in google_compute_instance.this : v.self_link])
}

output nic0_public_ip {
  value = { for k, v in google_compute_instance.this : k => v.network_interface.0.access_config.0.nat_ip }
}
