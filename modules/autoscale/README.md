# Auto-Scaling for Palo Alto Networks VM-Series

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| google | ~> 3.48 |
| null | ~> 2.1 |
| random | ~> 2.3 |

## Providers

| Name | Version |
|------|---------|
| google | ~> 3.48 |
| null | ~> 2.1 |
| random | ~> 2.3 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| autoscaler\_metrics | The map with the keys being metrics identifiers (e.g. custom.googleapis.com/VMSeries/panSessionUtilization).<br>Each of the contained objects has attribute `target` which is a numerical threshold for a scale-out or a scale-in.<br>Each zonal group grows until it satisfies all the targets.<br><br>Additional optional attribute `type` defines the metric as either `GAUGE` (the default), `DELTA_PER_SECOND`, or `DELTA_PER_MINUTE`.<br>For full specification, see the `metric` inside the [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_autoscaler). | `map` | <pre>{<br>  "custom.googleapis.com/VMSeries/panSessionThroughputKbps": {<br>    "target": 700000<br>  },<br>  "custom.googleapis.com/VMSeries/panSessionUtilization": {<br>    "target": 70<br>  }<br>}</pre> | no |
| bootstrap\_bucket | n/a | `string` | `""` | no |
| cooldown\_period | How much tame does it take for a spawned PA-VM to become functional on the initialization boot | `number` | `720` | no |
| dependencies | n/a | `list(string)` | `[]` | no |
| deployment\_name | Deployment Name that matches what is specified in Panorama GCP Plugin | `string` | n/a | yes |
| disk\_type | n/a | `string` | `"pd-ssd"` | no |
| image | Link to VM-Series PAN-OS image. Can be either a full self\_link, or one of the shortened forms per the [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#image). | `string` | `"https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/vmseries-byol-912"` | no |
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
| scale\_in\_control\_replicas\_fixed | Fixed number of VM instances that can be killed in each zone within the scale-in time window.<br>See `scale_in_control` in the [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_autoscaler). | `number` | `1` | no |
| scale\_in\_control\_time\_window\_sec | How many seconds autoscaling should look into the past when scaling in (down).<br>Default 30 minutes corresponds to the default custom metrics period of 5 minutes<br>and also to the considerable init time of a fresh instance. | `number` | `1800` | no |
| scopes | n/a | `list(string)` | <pre>[<br>  "https://www.googleapis.com/auth/compute.readonly",<br>  "https://www.googleapis.com/auth/cloud.useraccounts.readonly",<br>  "https://www.googleapis.com/auth/devstorage.read_only",<br>  "https://www.googleapis.com/auth/logging.write",<br>  "https://www.googleapis.com/auth/monitoring.write"<br>]</pre> | no |
| service\_account | IAM Service Account for running firewall instance (just the email) | `string` | `null` | no |
| ssh\_key | n/a | `string` | `""` | no |
| subnetworks | n/a | `list(string)` | n/a | yes |
| tags | n/a | `list(string)` | `[]` | no |
| update\_policy\_min\_ready\_sec | After underlying template changes (e.g. PAN-OS upgrade) and the new instance is being spawned,<br>how long to wait after it becomes online.<br>See `update_policy` in the [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_group_manager)." | `number` | `720` | no |
| update\_policy\_type | What to do when the underlying template changes (e.g. PAN-OS upgrade).<br>OPPORTUNISTIC is the only recommended value. Also PROACTIVE is allowed: it immediately<br>starts to re-create/delete instances and since this is not coordinated with<br>the instance group manager in other zone, it can easily lead to total outage.<br>It is thus feasible only in dev environments. Real environments should<br>perform a "Rolling Update" in GCP web interface. | `string` | `"OPPORTUNISTIC"` | no |
| zones | Map of zone names for the zonal IGMs | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| backends | Map of instance group (IG) identifiers, suitable for use in module lb\_tcp\_internal as input `backends`. |
| instance\_group\_manager | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
