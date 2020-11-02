output "nic0_public_ips" {
  value = var.nic0_public_ip ? google_compute_instance.this[*].network_interface[0].access_config[0].nat_ip : google_compute_instance.this[*].network_interface[0].ip_address
}
