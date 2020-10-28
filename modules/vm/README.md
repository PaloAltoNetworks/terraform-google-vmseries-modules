# Virtual Machine Module

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| google | ~> 3.30 |

## Providers

| Name | Version |
|------|---------|
| google | ~> 3.30 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create\_instance\_group | n/a | `bool` | `false` | no |
| image | n/a | `any` | n/a | yes |
| instances | n/a | <pre>map(object({<br>    name       = string,<br>    zone       = string,<br>    subnetwork = string<br>  }))</pre> | n/a | yes |
| machine\_type | n/a | `any` | n/a | yes |
| scopes | n/a | `list(string)` | <pre>[<br>  "https://www.googleapis.com/auth/cloud.useraccounts.readonly",<br>  "https://www.googleapis.com/auth/devstorage.read_only",<br>  "https://www.googleapis.com/auth/logging.write",<br>  "https://www.googleapis.com/auth/monitoring.write"<br>]</pre> | no |
| ssh\_key | n/a | `string` | `""` | no |
| startup\_script | n/a | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance\_group | n/a |
| nic0\_public\_ip | n/a |
| vm\_names | n/a |
| vm\_self\_link | n/a |
| vm\_self\_link\_list | Deprecated, use vm\_self\_link map instead. Only use for module lb\_tcp\_external input var.instances. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
