output instance_group_manager {
  value = google_compute_instance_group_manager.this
}

output backends {
  description = "Map of instance group (IG) identifiers, suitable for use in module lb_tcp_internal as input `backends`."
  value       = { for k, v in google_compute_instance_group_manager.this : k => v.instance_group }
}
