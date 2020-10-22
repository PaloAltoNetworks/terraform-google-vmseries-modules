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
