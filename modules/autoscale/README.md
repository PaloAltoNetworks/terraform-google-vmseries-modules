# Auto-Scaling for Palo Alto Networks VM-Series

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| google | ~> 3.35 |
| null | ~> 2.1 |
| random | ~> 2.3 |

## Providers

| Name | Version |
|------|---------|
| google | ~> 3.35 |
| null | ~> 2.1 |
| random | ~> 2.3 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| autoscaler\_metric\_name | n/a | `string` | n/a | yes |
| autoscaler\_metric\_target | n/a | `any` | n/a | yes |
| autoscaler\_metric\_type | n/a | `string` | n/a | yes |
| bootstrap\_bucket | n/a | `string` | `""` | no |
| cooldown\_period | How much tame does it take for a spawned PA-VM to become functional on the initialization boot | `number` | `720` | no |
| dependencies | n/a | `list(string)` | `[]` | no |
| deployment\_name | Deployment Name that matches what is specified in Panorama GCP Plugin | `string` | n/a | yes |
| disk\_type | n/a | `string` | `"pd-ssd"` | no |
| image | n/a | `string` | n/a | yes |
| machine\_type | n/a | `string` | n/a | yes |
| max\_replicas\_per\_zone | Maximum number of VM-series instances per *each* of the zones | `number` | `1` | no |
| mgmt\_interface\_swap | n/a | `string` | `""` | no |
| min\_cpu\_platform | n/a | `string` | `"Intel Broadwell"` | no |
| min\_replicas\_per\_zone | Minimum number of VM-series instances per *each* of the zones | `number` | `1` | no |
| named\_ports | (Optional) The list of named ports:<pre>named_ports = [<br>  {<br>    name = "http"<br>    port = "80"<br>  },<br>  {<br>    name = "app42"<br>    port = "4242"<br>  },<br>]</pre>The name identifies the backend port to receive the traffic from the global load balancers. | `list` | `[]` | no |
| nic0\_ip | n/a | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| nic0\_public\_ip | n/a | `bool` | `false` | no |
| nic1\_ip | n/a | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| nic1\_public\_ip | n/a | `bool` | `false` | no |
| nic2\_ip | n/a | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| nic2\_public\_ip | n/a | `bool` | `false` | no |
| pool | The self\_link of google\_compute\_target\_pool where the auto-created instances will be placed for healtchecking of External Load Balancer | `string` | `null` | no |
| prefix | Prefix to various GCP resource names | `string` | n/a | yes |
| region | GCP region to deploy to, if not set the default provider region is used. | `string` | `null` | no |
| scopes | n/a | `list(string)` | <pre>[<br>  "https://www.googleapis.com/auth/compute.readonly",<br>  "https://www.googleapis.com/auth/cloud.useraccounts.readonly",<br>  "https://www.googleapis.com/auth/devstorage.read_only",<br>  "https://www.googleapis.com/auth/logging.write",<br>  "https://www.googleapis.com/auth/monitoring.write"<br>]</pre> | no |
| service\_account | IAM Service Account for running firewall instance (just the email) | `string` | `null` | no |
| ssh\_key | n/a | `string` | `""` | no |
| subnetworks | n/a | `list(string)` | n/a | yes |
| tags | n/a | `list(string)` | `[]` | no |
| zones | Map of zone names for the zonal IGMs | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| backends | Map of instance group (IG) identifiers, suitable for use in module lb\_tcp\_internal as input `backends`. |
| instance\_group\_manager | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
