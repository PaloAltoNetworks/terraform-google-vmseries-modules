# VPC Networks Module for GCP

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| google | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allowed\_ports | n/a | `list(string)` | `[]` | no |
| allowed\_protocol | n/a | `string` | `"all"` | no |
| allowed\_sources | n/a | `list(string)` | `[]` | no |
| networks | n/a | `any` | n/a | yes |
| region | (Optional) GCP region for all the created subnetworks. Use a separate instance of this module to add subnetworks with another region (use `create_network=false`). | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| networks | n/a |
| subnetworks | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
