---
show_in_hub: false
---
# Palo Alto Networks VM-Series NGFW Module Example

A Terraform module example for deploying a VM-Series NGFW in GCP using the [metadata](https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/bootstrap-the-vm-series-firewall/choose-a-bootstrap-method#idf6412176-e973-488e-9d7a-c568fe1e33a9) bootstrap method.

This example can be used to familarize oneself with both the VM-Series NGFW and Terraform - it creates a single instance of virtualized firewall in a Security VPC with a management-only interface and lacks any traffic inspection.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_management_vpc"></a> [management\_vpc](#module\_management\_vpc) | ../../modules/vpc | n/a |
| <a name="module_vmseries"></a> [vmseries](#module\_vmseries) | ../../modules/vmseries | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_sources"></a> [allowed\_sources](#input\_allowed\_sources) | n/a | `any` | n/a | yes |
| <a name="input_bootstrap_options"></a> [bootstrap\_options](#input\_bootstrap\_options) | n/a | `any` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | n/a | `any` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | n/a | `any` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `any` | n/a | yes |
| <a name="input_ssh_keys"></a> [ssh\_keys](#input\_ssh\_keys) | n/a | `any` | n/a | yes |
| <a name="input_vmseries_image"></a> [vmseries\_image](#input\_vmseries\_image) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vmseries_address"></a> [vmseries\_address](#output\_vmseries\_address) | n/a |
| <a name="output_vmseries_ssh_command"></a> [vmseries\_ssh\_command](#output\_vmseries\_ssh\_command) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->