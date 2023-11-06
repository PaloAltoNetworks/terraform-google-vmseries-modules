output "subnetworks" {
  value = { for _, v in var.subnetworks : v.subnetwork_name
    => try(data.google_compute_subnetwork.this[v.subnetwork_name], google_compute_subnetwork.this[v.subnetwork_name], null)
  }
}

output "subnetworks_by_key" {
  description = "Map with subnetwork objects corresponding to input key (or index if list was provided) of `networks` variable."
  value = { for k, v in var.subnetworks :
    k => try(data.google_compute_subnetwork.this[v.subnetwork_name], google_compute_subnetwork.this[v.subnetwork_name])
  }
}