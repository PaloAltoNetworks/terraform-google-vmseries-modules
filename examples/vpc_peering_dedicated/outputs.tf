output "vmseries_private_ips" {
  description = "Private IP addresses of the vmseries instances."
  value       = { for k, v in module.vmseries : k => v.private_ips }
}

output "vmseries_public_ips" {
  description = "Public IP addresses of the vmseries instances."
  value       = { for k, v in module.vmseries : k => v.public_ips }
}

output "lbs_internal_ips" {
  description = "Private IP addresses of internal network loadbalancers."
  value       = { for k, v in module.lb_internal : k => v.address }
}

output "lbs_global_http" {
  description = "Public IP addresses of external Global HTTP(S) loadbalancers."
  value       = { for k, v in module.glb : k => v.address }
}

output "linux_vm_ips" {
  description = "Private IP addresses of Linux VMs."
  value       = { for k, v in resource.google_compute_instance.linux_vm : k => v.network_interface[0].network_ip }
}
