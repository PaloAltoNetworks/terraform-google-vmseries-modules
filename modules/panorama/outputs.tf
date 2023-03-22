output "panorama_public_ip" {
  description = "Private IP address of the Panorama instance."
  value       = var.attach_public_ip ? google_compute_instance.this.network_interface[0].access_config[0].nat_ip : null
}

output "panorama_private_ip" {
  description = "Public IP address of the Panorama instance."
  value       = google_compute_instance.this.network_interface[0].network_ip
}
