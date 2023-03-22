output "networks" {
  value = { for _, v in var.networks : v.name
    => try(data.google_compute_network.this[v.name], google_compute_network.this[v.name], null)
  }
}

output "subnetworks" {
  value = { for _, v in var.networks : v.subnetwork_name
    => try(data.google_compute_subnetwork.this[v.subnetwork_name], google_compute_subnetwork.this[v.subnetwork_name], null)
  }
}

output "networks_by_key" {
  description = "Map with network objects corresponding to input keys (or index if list was provided) of `networks` variable."
  value = { for k, v in var.networks :
    k => try(data.google_compute_network.this[v.name], google_compute_network.this[v.name])
  }
}

output "subnetworks_by_key" {
  description = "Map with subnetwork objects corresponding to input key (or index if list was provided) of `networks` variable."
  value = { for k, v in var.networks :
    k => try(data.google_compute_subnetwork.this[v.subnetwork_name], google_compute_subnetwork.this[v.subnetwork_name])
  }
}
