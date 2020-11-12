output subnetworks {
  value = merge(data.google_compute_subnetwork.this, google_compute_subnetwork.this)
}

output networks {
  value = merge(data.google_compute_network.this, google_compute_network.this)
}
