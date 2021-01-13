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
| files | Map of all files to copy to bucket. The keys are local paths, the values are remote paths. For example `{"dir/my.txt" = "config/init-cfg.txt"}` | `map(string)` | `{}` | no |
| name\_prefix | Prefix of the name of Google Cloud Storage bucket, followed by 10 random characters | `string` | `"paloaltonetworks-firewall-bootstrap-"` | no |
| service\_account | Optional IAM Service Account (just an email) that will be granted read-only access to this bucket | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket | n/a |
| bucket\_name | n/a |
| completion | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
