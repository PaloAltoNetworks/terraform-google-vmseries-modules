output names {
  value = { for k, v in google_compute_instance.this : k => v.name }
}

output self_links {
  value = { for k, v in google_compute_instance.this : k => v.self_link }
}

output instances {
  value = google_compute_instance.this
}

output instance_groups {
  value = google_compute_instance_group.this
}

output instance_group_self_links {
  value = { for k, v in google_compute_instance_group.this : k => v.self_link }
}

output private_ips {
  value = { for k, v in google_compute_instance.this :
    k => [for nic in v.network_interface : nic.network_ip]
  }
}

output public_ips {
  value = { for k, v in google_compute_instance.this :
    k => [
      for nic in v.network_interface :
      try(nic.access_config[0].nat_ip, null)
  ] }
}

output nic0_private_ips {
  value = { for k, v in google_compute_instance.this : k =>
    try(v.network_interface[0].network_ip, null)
  }
}

output nic1_private_ips {
  value = { for k, v in google_compute_instance.this : k =>
    try(v.network_interface[1].network_ip, null)
  }
}

output nic0_public_ips {
  value = { for k, v in google_compute_instance.this :
    k => v.network_interface[0].access_config[0].nat_ip
    if can(v.network_interface[0].access_config[0].nat_ip)
  }
}

output nic1_public_ips {
  value = { for k, v in google_compute_instance.this :
    k => v.network_interface[1].access_config[0].nat_ip
    if can(v.network_interface[1].access_config[0].nat_ip)
  }
}

output nic0_ips {
  description = "Map of IP addresses of interface at index 0, one entry per each instance. Contains public IP if one exists, otherwise private IP."
  value = { for k, v in google_compute_instance.this :
    k => try(v.network_interface[0].access_config[0].nat_ip, v.network_interface[0].network_ip, null)
  }
}

output nic1_ips {
  description = "Map of IP addresses of interface at index 1, one entry per each instance. Contains public IP if one exists, otherwise private IP."
  value = { for k, v in google_compute_instance.this :
    k => try(v.network_interface[1].access_config[0].nat_ip, v.network_interface[1].network_ip, null)
  }
}
