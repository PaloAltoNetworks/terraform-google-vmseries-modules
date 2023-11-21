output "network" {
  description = "Created or read network attributes."
  value       = try(data.google_compute_network.this[0], google_compute_network.this[0])
}

output "subnetworks" {
  description = "Map containing key, value pairs of created or read subnetwork attributes."
  value = { for k, v in var.subnetworks :
    k => try(data.google_compute_subnetwork.this[k], google_compute_subnetwork.this[k], null)
  }
}