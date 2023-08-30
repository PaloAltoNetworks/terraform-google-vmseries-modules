output "vpn_gw_name" {
  value       = google_compute_ha_vpn_gateway.ha_gateway.name
  description = "HA VPN gateway name"
}

output "vpn_gw_self_link" {
  value       = google_compute_ha_vpn_gateway.ha_gateway.self_link
  description = "HA VPN gateway self_link"
}

output "vpn_gw_local_address_1" {
  value       = google_compute_ha_vpn_gateway.ha_gateway.vpn_interfaces[0].ip_address
  description = "HA VPN gateway IP address 1"
}

output "vpn_gw_local_address_2" {
  value       = google_compute_ha_vpn_gateway.ha_gateway.vpn_interfaces[1].ip_address
  description = "HA VPN gateway IP address 2"
}

output "random_secrets_map" {
  value = {
    for k, v in module.vpn_ha :
    k => v.random_secret
  }
  sensitive   = true
  description = "HA VPN IPsec tunnels secrets that were randomly generated"
}