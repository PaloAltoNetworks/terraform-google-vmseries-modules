# Basic Example of vmseries Module Usage

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.3, < 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bootstrap"></a> [bootstrap](#module\_bootstrap) | ../../modules/bootstrap/ | n/a |
| <a name="module_iam_service_account"></a> [iam\_service\_account](#module\_iam\_service\_account) | ../../modules/iam_service_account/ | n/a |
| <a name="module_lb_tcp_internal_region0"></a> [lb\_tcp\_internal\_region0](#module\_lb\_tcp\_internal\_region0) | ../../modules/lb_tcp_internal | n/a |
| <a name="module_lb_tcp_internal_region1"></a> [lb\_tcp\_internal\_region1](#module\_lb\_tcp\_internal\_region1) | ../../modules/lb_tcp_internal | n/a |
| <a name="module_vmseries_region0"></a> [vmseries\_region0](#module\_vmseries\_region0) | ../../modules/vmseries | n/a |
| <a name="module_vmseries_region1"></a> [vmseries\_region1](#module\_vmseries\_region1) | ../../modules/vmseries | n/a |
| <a name="module_vpc_region0"></a> [vpc\_region0](#module\_vpc\_region0) | ../../modules/vpc | n/a |
| <a name="module_vpc_region1"></a> [vpc\_region1](#module\_vpc\_region1) | ../../modules/vpc | n/a |

## Resources

| Name | Type |
|------|------|
| [google_compute_route.region0](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_route) | resource |
| [google_compute_route.region1](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_route) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_global_access"></a> [allow\_global\_access](#input\_allow\_global\_access) | n/a | `any` | n/a | yes |
| <a name="input_allowed_sources"></a> [allowed\_sources](#input\_allowed\_sources) | n/a | `any` | n/a | yes |
| <a name="input_extlb_name"></a> [extlb\_name](#input\_extlb\_name) | n/a | `any` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | n/a | `string` | `"example-"` | no |
| <a name="input_project"></a> [project](#input\_project) | n/a | `any` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `any` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `any` | n/a | yes |
| <a name="input_region0"></a> [region0](#input\_region0) | n/a | `any` | n/a | yes |
| <a name="input_region1"></a> [region1](#input\_region1) | n/a | `any` | n/a | yes |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | n/a | `any` | n/a | yes |
| <a name="input_ssh_keys"></a> [ssh\_keys](#input\_ssh\_keys) | n/a | `any` | n/a | yes |
| <a name="input_vmseries_common"></a> [vmseries\_common](#input\_vmseries\_common) | n/a | `any` | n/a | yes |
| <a name="input_vmseries_region0"></a> [vmseries\_region0](#input\_vmseries\_region0) | n/a | `any` | n/a | yes |
| <a name="input_vmseries_region1"></a> [vmseries\_region1](#input\_vmseries\_region1) | n/a | `any` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->