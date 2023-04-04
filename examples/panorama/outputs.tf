output "panorama_private_ip" {
  description = "Private IP address of the Panorama instance."
  value       = { for k, v in module.panorama : k => v.panorama_private_ip }
}

output "panorama_public_ip" {
  description = "Public IP address of the Panorama instance."
  value       = { for k, v in module.panorama : k => v.panorama_public_ip }
}