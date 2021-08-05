# Basic Example of iam_service_account Module Usage

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.29, < 2.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 3.48 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 2.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 2.3 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bootstrap"></a> [bootstrap](#module\_bootstrap) | ../../modules/bootstrap/ |  |
| <a name="module_iam_service_account"></a> [iam\_service\_account](#module\_iam\_service\_account) | ../../modules/iam_service_account/ |  |
| <a name="module_iam_service_account_panorama"></a> [iam\_service\_account\_panorama](#module\_iam\_service\_account\_panorama) | ../../modules/iam_service_account/ |  |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | n/a | `any` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | n/a | `any` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | n/a | `any` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `any` | n/a | yes |
| <a name="input_service_account_id"></a> [service\_account\_id](#input\_service\_account\_id) | n/a | `any` | n/a | yes |
| <a name="input_zones"></a> [zones](#input\_zones) | n/a | `any` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
