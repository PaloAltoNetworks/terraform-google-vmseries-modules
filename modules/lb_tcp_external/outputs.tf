output forwarding_rule {
  description = "The self-link of the forwarding rule."
  value       = google_compute_forwarding_rule.this.self_link
}

output address {
  description = "The IP address of the forwarding rule."
  value       = google_compute_forwarding_rule.this.ip_address
}

output target_pool {
  description = "The self-link of the target pool."
  value       = google_compute_target_pool.this.self_link
}
