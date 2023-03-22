output "panorama_private_ip" {
  description = "Private IP address of the Panorama instance."
  value       = module.panorama.panorama_private_ip
}

output "panorama_public_ip" {
  description = "Public IP address of the Panorama instance."
  value       = module.panorama.panorama_public_ip
}
