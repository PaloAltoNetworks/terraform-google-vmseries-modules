output forwarding_rules {
  description = "The map of created forwarding rules."
  value       = google_compute_forwarding_rule.rule
}

output address {
  description = "The map of IP addresses of the forwarding rules."
  value       = { for k, v in google_compute_forwarding_rule.rule : k => v.ip_address }
}

output target_pool {
  description = "The self-link of the target pool."
  value       = google_compute_target_pool.this.self_link
}
