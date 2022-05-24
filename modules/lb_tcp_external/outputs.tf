output forwarding_rule {
  value = google_compute_forwarding_rule.default.*.self_link
}

output address {
  value = google_compute_forwarding_rule.default.ip_address
}

output target_pool {
  value = google_compute_target_pool.default.self_link
}
