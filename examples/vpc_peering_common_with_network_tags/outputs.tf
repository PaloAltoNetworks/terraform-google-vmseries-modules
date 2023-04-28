output "vmseries_private_ips_region_1" {
  description = "Private IP addresses of the vmseries instances in region-1."
  value       = { for k, v in module.vmseries_region_1 : k => v.private_ips }
}

output "vmseries_private_ips_region_2" {
  description = "Private IP addresses of the vmseries instances in region-2."
  value       = { for k, v in module.vmseries_region_2 : k => v.private_ips }
}

output "vmseries_public_ips_region_1" {
  description = "Public IP addresses of the vmseries instances in region-1."
  value       = { for k, v in module.vmseries_region_1 : k => v.public_ips }
}

output "vmseries_public_ips_region_2" {
  description = "Public IP addresses of the vmseries instances in region-2."
  value       = { for k, v in module.vmseries_region_2 : k => v.public_ips }
}

output "lbs_internal_ips_region_1" {
  description = "Private IP addresses of internal network loadbalancers in region-1."
  value       = { for k, v in module.lb_internal_region_1 : k => v.address }
}

output "lbs_internal_ips_region_2" {
  description = "Private IP addresses of internal network loadbalancers in region-2."
  value       = { for k, v in module.lb_internal_region_2 : k => v.address }
}

output "lbs_external_ips_region_1" {
  description = "Public IP addresses of external network loadbalancers in region-1."
  value       = { for k, v in module.lb_external_region_1 : k => v.ip_addresses }
}

output "lbs_external_ips_region_2" {
  description = "Public IP addresses of external network loadbalancers in region-2."
  value       = { for k, v in module.lb_external_region_2 : k => v.ip_addresses }
}

output "linux_vm_ips_region_1" {
  description = "Private IP addresses of Linux VMs in region-1."
  value       = { for k, v in resource.google_compute_instance.linux_vm_region_1 : k => v.network_interface[0].network_ip }
}

output "linux_vm_ips_region_2" {
  description = "Private IP addresses of Linux VMs in region-2."
  value       = { for k, v in resource.google_compute_instance.linux_vm_region_2 : k => v.network_interface[0].network_ip }
}