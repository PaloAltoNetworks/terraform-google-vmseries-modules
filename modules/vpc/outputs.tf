output "network" {
  value = try(data.google_compute_network.this[0], google_compute_network.this[0])
}
output "subnetworks" {
  value = { for k, v in var.subnetworks :
    k => try(data.google_compute_subnetwork.this[v.subnetwork_name], google_compute_subnetwork.this[v.subnetwork_name], null)
  }
}