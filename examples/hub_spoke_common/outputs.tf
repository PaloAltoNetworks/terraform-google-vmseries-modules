output "ext_lb_url" {
  value = "http://${module.lb_tcp_external.ip_addresses["rule1"]}"
}

output "ssh_to_spoke2" {
  value = "ssh ${var.spoke_vm_user}@${module.lb_tcp_external.ip_addresses["rule2"]}"
}

output "vmseries01_access" {
  value = "https://${module.vmseries["fw01"].public_ips[1]}"
}

output "vmseries02_access" {
  value = "https://${module.vmseries["fw02"].public_ips[1]}"
}
