# Basic Example of vmseries Module Usage

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bootstrap"></a> [bootstrap](#module\_bootstrap) | ../../modules/bootstrap/ |  |
| <a name="module_iam_service_account"></a> [iam\_service\_account](#module\_iam\_service\_account) | ../../modules/iam_service_account/ |  |
| <a name="module_lb_tcp_external"></a> [lb\_tcp\_external](#module\_lb\_tcp\_external) | ../../modules/lb_tcp_external/ |  |
| <a name="module_lb_tcp_internal"></a> [lb\_tcp\_internal](#module\_lb\_tcp\_internal) | ../../modules/lb_tcp_internal |  |
| <a name="module_mgmt_cloud_nat"></a> [mgmt\_cloud\_nat](#module\_mgmt\_cloud\_nat) | terraform-google-modules/cloud-nat/google | =1.2 |
| <a name="module_vmseries"></a> [vmseries](#module\_vmseries) | ../../modules/vmseries |  |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../../modules/vpc |  |

## Resources

| Name | Type |
|------|------|
| [google_compute_network_peering.from_common_vdi_to_trust](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering) | resource |
| [google_compute_network_peering.from_trust_to_common_vdi](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering) | resource |
| [google_compute_network_peering.from_trust_to_vdi](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering) | resource |
| [google_compute_network_peering.from_vdi_to_trust](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering) | resource |
| [google_compute_zones.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_sources"></a> [allowed\_sources](#input\_allowed\_sources) | n/a | `any` | n/a | yes |
| <a name="input_extlb_name"></a> [extlb\_name](#input\_extlb\_name) | n/a | `any` | n/a | yes |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | n/a | `any` | n/a | yes |
| <a name="input_image_uri"></a> [image\_uri](#input\_image\_uri) | n/a | `any` | `null` | no |
| <a name="input_project"></a> [project](#input\_project) | n/a | `any` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `any` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `any` | n/a | yes |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | n/a | `any` | n/a | yes |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_self_link"></a> [self\_link](#output\_self\_link) | n/a |
| <a name="output_ssh_command"></a> [ssh\_command](#output\_ssh\_command) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->