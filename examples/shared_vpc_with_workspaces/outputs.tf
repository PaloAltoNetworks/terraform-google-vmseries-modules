output "info" {
  description = "Basic Known information output regarding region/environment/projectID"
  value = {
    region     = local.region
    env        = local.environment
    prefix     = var.prefix
    project_id = var.project_id
  }
}

output "subnetworks" {
  description = "GCP Subnetwork Detailed Information Output"
  value = local.subnetwork_map_detail
}

output "fw_interfaces" {
  description = "VM-Series Firewall Interface Output Details"
  value = module.firewalls.firewall_interfaces
}