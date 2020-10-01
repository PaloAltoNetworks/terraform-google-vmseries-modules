output subnetwork {
  value = google_compute_subnetwork.this
}

output network {
  value = google_compute_network.this
}

output nicspec {
  value = [ for v in values(google_compute_subnetwork.this): {
    subnetwork = v.self_link
  } ]
}