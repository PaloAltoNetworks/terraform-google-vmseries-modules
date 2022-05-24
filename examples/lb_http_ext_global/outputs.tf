output "internal_url" {
  value = "http://${module.ilb.address}"
}

output "global_url" {
  value = "http://${module.glb.address}"
}

output "regional_url" {
  value = "http://${local.extlb_address}"
}

output "public_ips" {
  value = { for k, v in module.vmseries : k => v.public_ips }
}