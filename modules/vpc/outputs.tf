output subnetwork {
  value = google_compute_subnetwork.this
}

output vpc_name {
  value = google_compute_network.this.name
}

output vpc_id {
  value = google_compute_network.this.id
}

output vpc_self_link {
  value = google_compute_network.this.self_link
}
