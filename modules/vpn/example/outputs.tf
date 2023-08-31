output "local_ipsec_gw1" {
  value       = module.vpn.vpn_gw_local_address_1
  description = "Cloud VPN gateway IP address 1"
}

output "local_ipsec_gw2" {
  value       = module.vpn.vpn_gw_local_address_2
  description = "Cloud VPN gateway IP address 2"
}

output "random_secrets_map" {
  value       = module.vpn.random_secrets_map
  sensitive   = true
  description = "IPsec VPN tunnels secrets that were randomly generated."
}

output "gw_id" {
  value       = module.vpn.vpn_gw_self_link
  description = "IPsec VPN tunnels secrets that were randomly generated."
}

output "gw_name" {
  value       = module.vpn.vpn_gw_name
  description = "IPsec VPN tunnels secrets that were randomly generated."
}