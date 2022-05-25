output "EXT_LB_URL" {
  value = "http://${module.lb_tcp_external.ip_addresses["rule1"]}" 
}

output "SSH_TO_SPOKE2" {
  value = "ssh ${var.spoke_vm_user}@${module.lb_tcp_external.ip_addresses["rule2"]}"
}

output VMSERIES01_ACCESS {
  value = "https://${module.vmseries["fw01"].public_ips[1]}"
}

output VMSERIES02_ACCESS {
  value = "https://${module.vmseries["fw02"].public_ips[1]}"
}
