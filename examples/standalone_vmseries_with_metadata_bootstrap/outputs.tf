output "vmseries_address" {
  value = module.vmseries.public_ips[0]
}

output "vmseries_ssh_command" {
  value = "ssh admin@${module.vmseries.public_ips[0]}"
}