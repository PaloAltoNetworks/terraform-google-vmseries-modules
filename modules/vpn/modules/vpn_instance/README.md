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
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create\_vpn\_gateway | create a VPN gateway | `bool` | `true` | no |
| external\_vpn\_gateway\_description | An optional description of external VPN Gateway | `string` | `"Terraform managed external VPN gateway"` | no |
| keepalive\_interval | The interval in seconds between BGP keepalive messages that are sent to the peer. | `number` | `20` | no |
| labels | Labels for vpn components | `map(string)` | `{}` | no |
| name | VPN gateway name, and prefix used for dependent resources. | `string` | n/a | yes |
| network | VPC used for the gateway and routes. | `string` | n/a | yes |
| peer\_external\_gateway | Configuration of an external VPN gateway to which this VPN is connected. | <pre>object({<br>    name            = optional(string)<br>    redundancy_type = optional(string)<br>    interfaces = list(object({<br>      id         = number<br>      ip_address = string<br>    }))<br>  })</pre> | `null` | no |
| peer\_gcp\_gateway | Self Link URL of the peer side HA GCP VPN gateway to which this VPN tunnel is connected. | `string` | `null` | no |
| project\_id | Project where resources will be created. | `string` | n/a | yes |
| region | Region used for resources. | `string` | n/a | yes |
| route\_priority | Route priority, defaults to 1000. | `number` | `1000` | no |
| router\_advertise\_config | Router custom advertisement configuration, ip\_ranges is a map of address ranges and descriptions. | <pre>object({<br>    groups    = list(string)<br>    ip_ranges = map(string)<br>    mode      = optional(string)<br>  })</pre> | `null` | no |
| router\_asn | Router ASN used for auto-created router. | `number` | `64514` | no |
| router\_name | Name of router, leave blank to create one. | `string` | `""` | no |
| stack\_type | The IP stack type will apply to all the tunnels associated with this VPN gateway. | `string` | `"IPV4_ONLY"` | no |
| tunnels | VPN tunnel configurations, bgp\_peer\_options is usually null. | <pre>map(object({<br>    bgp_peer = object({<br>      address = string<br>      asn     = number<br>    })<br>    bgp_session_name = optional(string)<br>    bgp_peer_options = optional(object({<br>      ip_address          = optional(string)<br>      advertise_groups    = optional(list(string))<br>      advertise_ip_ranges = optional(map(string))<br>      advertise_mode      = optional(string)<br>      route_priority      = optional(number)<br>    }))<br>    bgp_session_range               = optional(string)<br>    ike_version                     = optional(number)<br>    vpn_gateway_interface           = optional(number)<br>    peer_external_gateway_interface = optional(number)<br>    shared_secret                   = optional(string, "")<br>  }))</pre> | `{}` | no |
| vpn\_gateway\_self\_link | self\_link of existing VPN gateway to be used for the vpn tunnel | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| external\_gateway | External VPN gateway resource. |
| gateway | HA VPN gateway resource. |
| name | VPN gateway name. |
| random\_secret | Generated secret. |
| router | Router resource (only if auto-created). |
| router\_name | Router name. |
| self\_link | HA VPN gateway self link. |
| tunnel\_names | VPN tunnel names. |
| tunnel\_self\_links | VPN tunnel self links. |
| tunnels | VPN tunnel resources. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
