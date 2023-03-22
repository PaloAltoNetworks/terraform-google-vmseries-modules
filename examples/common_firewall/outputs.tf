output "vmseries_private_ips" {
  value = { for k, v in module.vmseries : k => v.private_ips }
}
output "vmseries_public_ips" {
  value = { for k, v in module.vmseries : k => v.public_ips }
}
