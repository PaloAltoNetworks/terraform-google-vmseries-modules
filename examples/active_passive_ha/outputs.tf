output "vmseries01_access" {
  description = "Management URL for vmseries01."
  value       = "https://${module.vmseries["vmseries01"].public_ips[1]}"
}

output "vmseries02_access" {
  description = "Management URL for vmseries02."
  value       = "https://${module.vmseries["vmseries02"].public_ips[1]}"
}

output "external_nat_ip" {
  value = google_compute_address.external_nat_ip.address
}
