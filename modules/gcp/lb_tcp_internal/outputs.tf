output forwarding_rule {
  value = google_compute_forwarding_rule.this.self_link
}

output address {
  value = google_compute_forwarding_rule.this.ip_address
}

