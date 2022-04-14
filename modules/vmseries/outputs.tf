output "instance" {
  value = google_compute_instance.this
}

output "self_link" {
  value = google_compute_instance.this.self_link
}

output "instance_group" {
  value = try(google_compute_instance_group.this[0], null)
}

output "instance_group_self_link" {
  value = try(google_compute_instance_group.this[0].self_link, null)
}

output "private_ips" {
  value = { for k, v in google_compute_instance.this.network_interface : k => v.network_ip }
}

output "public_ips" {
  value = { for k, v in google_compute_instance.this.network_interface : k => v.access_config[0].nat_ip if length(v.access_config) != 0 }
}
