# Google Cloud Storage Bucket For Initial Boot Of Palo Alto Networks VM-Series

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| google | ~> 3.30 |
| null | ~> 2.1 |
| random | ~> 2.3 |

## Providers

| Name | Version |
|------|---------|
| google | ~> 3.30 |
| null | ~> 2.1 |
| random | ~> 2.3 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket\_name | n/a | `any` | n/a | yes |
| config | n/a | `list(string)` | `[]` | no |
| content | n/a | `list(string)` | `[]` | no |
| file\_location | n/a | `any` | n/a | yes |
| license | n/a | `list(string)` | `[]` | no |
| service\_account | Optional IAM Service Account (just an email) that will be granted read-only access to this bucket | `string` | `null` | no |
| software | n/a | `list` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket\_name | n/a |
| completion | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
