output vm_names {
  value = { for k, v in google_compute_instance.default : k => v.name }
}

output vm_self_link {
  value = { for k, v in google_compute_instance.default : k => v.self_link }
}

output vm_self_link_list {
  description = "Deprecated, use vm_self_link map instead. Only use for module lb_tcp_external input var.instances."
  value       = sort([for k, v in google_compute_instance.default : v.self_link])
}

output instance_group {
  value = { for k, v in google_compute_instance_group.default : k => v.self_link }
}

output instance_group_list {
  value = sort([for k, v in google_compute_instance_group.default : v.self_link])
}

output nic0_public_ip {
  value = { for k, v in google_compute_instance.default : k => v.network_interface.0.access_config.0.nat_ip }
}
