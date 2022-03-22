output "nic0_public_ip" {
  value = var.attach_public_ip ? google_compute_instance.this.network_interface[0].access_config[0].nat_ip : null
}

output "nic0_private_ip" {
  value = google_compute_instance.this.network_interface[0].network_ip
}
