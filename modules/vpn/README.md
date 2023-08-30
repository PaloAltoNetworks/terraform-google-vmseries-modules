# VPN

This module deploys HA VPN gateway with 2 or more VPN tunnels.

The module relies on Google's `terraform-google-vpn` Terraform module and might be considered as a wrapper around it.

## Reference
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2, < 2.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.58 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.58 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpn_ha"></a> [vpn\_ha](#module\_vpn\_ha) | terraform-google-modules/vpn/google//modules/vpn_ha | 3.0.1 |

### Resources

| Name | Type |
|------|------|
| [google_compute_ha_vpn_gateway.ha_gateway](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ha_vpn_gateway) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Region to deploy VPN gateway in | `string` | n/a | yes |
| <a name="input_vpc_network_id"></a> [vpc\_network\_id](#input\_vpc\_network\_id) | VPC network ID that should be used for deployment | `string` | n/a | yes |
| <a name="input_vpn_config"></a> [vpn\_config](#input\_vpn\_config) | VPN configuration from GCP to on-prem or from GCP to GCP.<br>If you'd like secrets to be randomly generated set `shared_secret` to empty string ("").<br><br>Example:<pre>vpn_config = {<br>  router_asn    = 65000<br>  local_network = "vpc-vpn"<br><br>  router_advertise_config = {<br>    ip_ranges = {<br>      "10.10.0.0/16" : "GCP range 1"<br>    }<br>    mode   = "CUSTOM"<br>    groups = null<br>  }<br><br>  instances = {<br>    vpn-to-onprem = {<br>      name = "vpn-to-onprem",<br>      peer_external_gateway = {<br>        redundancy_type = "TWO_IPS_REDUNDANCY"<br>        interfaces = [{<br>          id         = 0<br>          ip_address = "1.1.1.1"<br>          }, {<br>          id         = 1<br>          ip_address = "2.2.2.2"<br>        }]<br>      },<br>      tunnels = {<br>        remote0 = {<br>          bgp_peer = {<br>            address = "169.254.1.2"<br>            asn     = 65001<br>          }<br>          bgp_peer_options                = null<br>          bgp_session_range               = "169.254.1.1/30"<br>          ike_version                     = 2<br>          vpn_gateway_interface           = 0<br>          peer_external_gateway_interface = 0<br>          shared_secret                   = "secret"<br>        }<br>        remote1 = {<br>          bgp_peer = {<br>            address = "169.254.1.6"<br>            asn     = 65001<br>          }<br>          bgp_peer_options                = null<br>          bgp_session_range               = "169.254.1.5/30"<br>          ike_version                     = 2<br>          vpn_gateway_interface           = 1<br>          peer_external_gateway_interface = 1<br>          shared_secret                   = "secret"<br>        }<br>      }<br>    }<br>  }<br>}</pre> | `any` | n/a | yes |
| <a name="input_vpn_gateway_name"></a> [vpn\_gateway\_name](#input\_vpn\_gateway\_name) | VPN gateway name | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_random_secrets_map"></a> [random\_secrets\_map](#output\_random\_secrets\_map) | HA VPN IPsec tunnels secrets that were randomly generated |
| <a name="output_vpn_gw_local_address_1"></a> [vpn\_gw\_local\_address\_1](#output\_vpn\_gw\_local\_address\_1) | HA VPN gateway IP address 1 |
| <a name="output_vpn_gw_local_address_2"></a> [vpn\_gw\_local\_address\_2](#output\_vpn\_gw\_local\_address\_2) | HA VPN gateway IP address 2 |
| <a name="output_vpn_gw_name"></a> [vpn\_gw\_name](#output\_vpn\_gw\_name) | HA VPN gateway name |
| <a name="output_vpn_gw_self_link"></a> [vpn\_gw\_self\_link](#output\_vpn\_gw\_self\_link) | HA VPN gateway self\_link |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2, < 2.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | == 4.58 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | == 4.58 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpn_ha"></a> [vpn\_ha](#module\_vpn\_ha) | terraform-google-modules/vpn/google | 3.0.1 |

## Resources

| Name | Type |
|------|------|
| [google_compute_ha_vpn_gateway.ha_gateway](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ha_vpn_gateway) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Region to deploy VPN gateway in | `string` | n/a | yes |
| <a name="input_vpc_network_id"></a> [vpc\_network\_id](#input\_vpc\_network\_id) | VPC network ID that should be used for deployment | `string` | n/a | yes |
| <a name="input_vpn"></a> [vpn](#input\_vpn) | VPN configuration from GCP to on-prem or from GCP to GCP.<br>If you'd like secrets to be randomly generated set `shared_secret` to empty string ("").<br><br>Example:<pre>vpn = {<br>router_asn    = 65000<br>local_network = "vpc-vpn"<br><br>router_advertise_config = {<br>  ip_ranges = {<br>    "10.10.0.0/16" : "GCP range 1"<br>  }<br>  mode   = "CUSTOM"<br>  groups = null<br>}<br><br>instances = {<br>  vpn-to-onprem = {<br>    name = "vpn-to-onprem",<br>    peer_external_gateway = {<br>      redundancy_type = "TWO_IPS_REDUNDANCY"<br>      interfaces = [{<br>        id         = 0<br>        ip_address = "1.1.1.1"<br>        }, {<br>        id         = 1<br>        ip_address = "2.2.2.2"<br>      }]<br>    },<br>    tunnels = {<br>      remote0 = {<br>        bgp_peer = {<br>          address = "169.254.1.2"<br>          asn     = 65001<br>        }<br>        bgp_peer_options                = null<br>        bgp_session_range               = "169.254.1.1/30"<br>        ike_version                     = 2<br>        vpn_gateway_interface           = 0<br>        peer_external_gateway_interface = 0<br>        shared_secret                   = "secret"<br>      }<br>      remote1 = {<br>        bgp_peer = {<br>          address = "169.254.1.6"<br>          asn     = 65001<br>        }<br>        bgp_peer_options                = null<br>        bgp_session_range               = "169.254.1.5/30"<br>        ike_version                     = 2<br>        vpn_gateway_interface           = 1<br>        peer_external_gateway_interface = 1<br>        shared_secret                   = "secret"<br>      }<br>    }<br>  }<br>}</pre> | `any` | n/a | yes |
| <a name="input_vpn_gateway_name"></a> [vpn\_gateway\_name](#input\_vpn\_gateway\_name) | VPN gateway name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_local_ipsec_gw2_address_2"></a> [local\_ipsec\_gw2\_address\_2](#output\_local\_ipsec\_gw2\_address\_2) | HA VPN gateway IP address 2 |
| <a name="output_local_ipsec_gw_address_1"></a> [local\_ipsec\_gw\_address\_1](#output\_local\_ipsec\_gw\_address\_1) | HA VPN gateway IP address 1 |
| <a name="output_random_secrets_map"></a> [random\_secrets\_map](#output\_random\_secrets\_map) | HA VPN IPsec tunnels secrets that were randomly generated |
| <a name="output_vpn_gateway_name"></a> [vpn\_gateway\_name](#output\_vpn\_gateway\_name) | HA VPN gateway name |
| <a name="output_vpn_gateway_self_link"></a> [vpn\_gateway\_self\_link](#output\_vpn\_gateway\_self\_link) | HA VPN gateway self\_link |
<!-- END_TF_DOCS -->