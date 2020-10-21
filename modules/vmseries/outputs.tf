output names {
  value = { for k, v in google_compute_instance.this : k => v.name }
}

output self_links {
  value = { for k, v in google_compute_instance.this : k => v.self_link }
}

output public_ips {
  value = { for k, v in google_compute_instance.this :
    k => [
      for nic in v.network_interface :
      try(nic.access_config.0.nat_ip, null)
  ] }
}

output nic0_public_ips {
  value = { for k, v in google_compute_instance.this :
    k => v.network_interface.0.access_config.0.nat_ip
    if try(v.network_interface.0.access_config.0.nat_ip, null) != null
  }
}

output nic1_public_ips {
  value = { for k, v in google_compute_instance.this :
    k => v.network_interface.1.access_config.0.nat_ip
    if try(v.network_interface.1.access_config.0.nat_ip, null) != null
  }
}

output instance_group_self_links {
  value = { for k, v in google_compute_instance_group.this : k => v.self_link }
}
