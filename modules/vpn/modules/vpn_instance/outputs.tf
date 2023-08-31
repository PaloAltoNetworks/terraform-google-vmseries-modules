output "external_gateway" {
  description = "External VPN gateway resource."
  value = (
    var.peer_external_gateway != null
    ? google_compute_external_vpn_gateway.external_gateway[0]
    : null
  )
}

output "tunnels" {
  description = "VPN tunnel resources."
  sensitive   = true
  value = {
    for name in keys(var.tunnels) :
    name => google_compute_vpn_tunnel.tunnels[name]
  }
}

output "tunnel_names" {
  description = "VPN tunnel names."
  value = {
    for name in keys(var.tunnels) :
    name => google_compute_vpn_tunnel.tunnels[name].name
  }
}

output "tunnel_self_links" {
  description = "VPN tunnel self links."
  sensitive   = true
  value = {
    for name in keys(var.tunnels) :
    name => google_compute_vpn_tunnel.tunnels[name].self_link
  }
}

output "random_secret" {
  description = "Generated secret."
  sensitive   = true
  value       = local.secret
}
