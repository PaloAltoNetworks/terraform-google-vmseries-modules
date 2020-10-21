output subnetworks {
  value = { for k, v in local.subnetworks : k =>
    # null happens when we `terraform destroy` an empty state
    try(data.google_compute_subnetwork.this[k], null)
  }
}

output networks {
  value = { for k, v in local.networks : k =>
    try(data.google_compute_network.this[k], null)
  }
}

output nicspec {
  value = [for v in var.networks : {
    subnetwork = try(data.google_compute_subnetwork.this[v.subnetwork_name].self_link, null)
  }]
}
