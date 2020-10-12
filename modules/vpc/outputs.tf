output subnetworks {
  value = google_compute_subnetwork.this
}

output networks {
  value = google_compute_network.this
}

output nicspec {
  value = [for v in var.networks : {
    subnetwork = try(data.google_compute_subnetwork.this["${v.name}-${var.region}"].self_link, null)
  }]
}
