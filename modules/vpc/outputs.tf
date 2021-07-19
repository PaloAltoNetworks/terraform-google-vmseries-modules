output "subnetworks" {
  value = { for _, v in var.networks : v.subnetwork_name
    => try(data.google_compute_subnetwork.this[v.subnetwork_name], google_compute_subnetwork.this[v.subnetwork_name], null)
  }
}

output "networks" {
  value = { for _, v in var.networks : v.name
    => try(data.google_compute_network.this[v.name], google_compute_network.this[v.name], null)
  }
}
