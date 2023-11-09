output "vmseries_private_ips" {
  description = "Private IP addresses of the vmseries instances."
  value       = { for k, v in module.vmseries : k => v.private_ips }
}

output "vmseries_public_ips" {
  description = "Public IP addresses of the vmseries instances."
  value       = { for k, v in module.vmseries : k => v.public_ips }
}