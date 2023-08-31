# Cloud VPN HA Module
This module makes it easy to deploy either GCP-to-GCP or GCP-to-On-prem VPN instance (connection) for [Cloud HA VPN](https://cloud.google.com/vpn/docs/concepts/overview#ha-vpn).
VPN instance is represented by 1..4 VPN tunnels that taget remote VPN gateway(s) located in a single remote location. Remote VPN gateway(s) might have singe IP address (`redundancy_type = "SINGLE_IP_INTERNALLY_REDUNDANT"`) or 2 IP addresses (`redundancy_type = "TWO_IPS_REDUNDANCY"`).

Module requires that HA VPN Gateway is pre-created and is passed in the module as a parameter variable.

## Examples

```hcl
resource "google_compute_ha_vpn_gateway" "ha_gateway" {
  name       = var.vpn_gateway_name
  project    = var.project
  region     = var.region
  network    = var.network
}

module "vpn_ha" {
  source  = "../vpn_instance"
  
  for_each = var.vpn_config.instances

  project    = var.project
  region     = var.region
  network    = var.network

  name = each.value.name

  router_name = "rtr-${each.key}"

  peer_external_gateway = try(each.value.peer_external_gateway, null)
  peer_gcp_gateway      = try(each.value.peer_gcp_gateway, null)

  router_asn = var.vpn_config.router_asn
  tunnels    = each.value.tunnels

  vpn_gateway_self_link   = google_compute_ha_vpn_gateway.ha_gateway.self_link
  router_advertise_config = var.vpn_config.router_advertise_config
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.2, < 2.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.74, < 5.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 4.74, < 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.4 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.74, < 5.0 |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | >= 4.74, < 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.4 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [google-beta_google_compute_vpn_tunnel.tunnels](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_vpn_tunnel) | resource |
| [google_compute_external_vpn_gateway.external_gateway](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_external_vpn_gateway) | resource |
| [google_compute_router.router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_interface.router_interface](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_interface) | resource |
| [google_compute_router_peer.bgp_peer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_peer) | resource |
| [random_id.secret](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_external_vpn_gateway_description"></a> [external\_vpn\_gateway\_description](#input\_external\_vpn\_gateway\_description) | An optional description of external VPN Gateway | `string` | `"Terraform managed external VPN gateway"` | no |
| <a name="input_keepalive_interval"></a> [keepalive\_interval](#input\_keepalive\_interval) | The interval in seconds between BGP keepalive messages that are sent to the peer. | `number` | `20` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels for vpn components | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | VPN gateway name, and prefix used for dependent resources. | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | VPC used for the gateway and routes. | `string` | n/a | yes |
| <a name="input_peer_external_gateway"></a> [peer\_external\_gateway](#input\_peer\_external\_gateway) | Configuration of an external VPN gateway to which this VPN is connected. | <pre>object({<br>    name            = optional(string)<br>    redundancy_type = optional(string)<br>    interfaces = list(object({<br>      id         = number<br>      ip_address = string<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_peer_gcp_gateway"></a> [peer\_gcp\_gateway](#input\_peer\_gcp\_gateway) | Self Link URL of the peer side HA GCP VPN gateway to which this VPN tunnel is connected. | `string` | `null` | no |
| <a name="input_project"></a> [project](#input\_project) | Project where resources will be created. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region used for resources. | `string` | n/a | yes |
| <a name="input_route_priority"></a> [route\_priority](#input\_route\_priority) | Route priority, defaults to 1000. | `number` | `1000` | no |
| <a name="input_router_advertise_config"></a> [router\_advertise\_config](#input\_router\_advertise\_config) | Router custom advertisement configuration, ip\_ranges is a map of address ranges and descriptions. | <pre>object({<br>    groups    = list(string)<br>    ip_ranges = map(string)<br>    mode      = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_router_asn"></a> [router\_asn](#input\_router\_asn) | Router ASN used for auto-created router. | `number` | `64514` | no |
| <a name="input_router_name"></a> [router\_name](#input\_router\_name) | Existing Cloud Router name. | `string` | `""` | no |
| <a name="input_tunnels"></a> [tunnels](#input\_tunnels) | VPN tunnel configurations, bgp\_peer\_options is usually null. | <pre>map(object({<br>    bgp_peer = object({<br>      address = string<br>      asn     = number<br>    })<br>    bgp_session_name = optional(string)<br>    bgp_peer_options = optional(object({<br>      ip_address          = optional(string)<br>      advertise_groups    = optional(list(string))<br>      advertise_ip_ranges = optional(map(string))<br>      advertise_mode      = optional(string)<br>      route_priority      = optional(number)<br>    }))<br>    bgp_session_range               = optional(string)<br>    ike_version                     = optional(number)<br>    vpn_gateway_interface           = optional(number)<br>    peer_external_gateway_interface = optional(number)<br>    shared_secret                   = optional(string, "")<br>  }))</pre> | `{}` | no |
| <a name="input_vpn_gateway_self_link"></a> [vpn\_gateway\_self\_link](#input\_vpn\_gateway\_self\_link) | self\_link of existing VPN gateway to be used for the vpn tunnel. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_external_gateway"></a> [external\_gateway](#output\_external\_gateway) | External VPN gateway resource. |
| <a name="output_random_secret"></a> [random\_secret](#output\_random\_secret) | Generated secret. |
| <a name="output_tunnel_names"></a> [tunnel\_names](#output\_tunnel\_names) | VPN tunnel names. |
| <a name="output_tunnel_self_links"></a> [tunnel\_self\_links](#output\_tunnel\_self\_links) | VPN tunnel self links. |
| <a name="output_tunnels"></a> [tunnels](#output\_tunnels) | VPN tunnel resources. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
