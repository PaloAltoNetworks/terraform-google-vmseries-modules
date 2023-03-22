output "ext_lb_url" {
  description = "External load balancer's frontend URL that resolves to spoke1 web servers after VM-Series inspection."
  value       = "http://${module.lb_external.ip_addresses["rule1"]}"
}

output "ssh_to_spoke2" {
  description = "External load balancer's frontend address that opens SSH session to spoke2-vm1 after VM-Series inspection."
  value       = "ssh ${var.spoke_vm_user}@${module.lb_external.ip_addresses["rule2"]}"
}

output "vmseries01_access" {
  description = "Management URL for vmseries01."
  value       = "https://${module.vmseries["vmseries01"].public_ips[1]}"
}

output "vmseries02_access" {
  description = "Management URL for vmseries02."
  value       = "https://${module.vmseries["vmseries02"].public_ips[1]}"
}
