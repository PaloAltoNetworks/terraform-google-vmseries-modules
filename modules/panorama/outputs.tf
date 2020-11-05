output "nic0_public_ips" {
  value = var.public_nat ? { for k, v in google_compute_instance.this : k =>
    v.network_interface[0].access_config[0].nat_ip
  } : {}
}

output "nic0_private_ips" {
  value = { for k, v in google_compute_instance.this : k =>
    v.network_interface[0].network_ip
  }
}
