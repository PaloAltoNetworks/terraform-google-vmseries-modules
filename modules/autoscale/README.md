# Auto-Scaling for Palo Alto Networks VM-Series

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 3.48 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 2.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 2.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 3.48 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 2.1 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 2.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_autoscaler.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_autoscaler) | resource |
| [google_compute_instance_group_manager.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_group_manager) | resource |
| [google_compute_instance_template.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template) | resource |
| [google_pubsub_subscription.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription) | resource |
| [google_pubsub_subscription_iam_member.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription_iam_member) | resource |
| [google_pubsub_topic.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [null_resource.dependency_getter](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_id.autoscaler](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [google_compute_default_service_account.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_default_service_account) | data source |
| [google_project.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_autoscaler_metrics"></a> [autoscaler\_metrics](#input\_autoscaler\_metrics) | The map with the keys being metrics identifiers (e.g. custom.googleapis.com/VMSeries/panSessionUtilization).<br>Each of the contained objects has attribute `target` which is a numerical threshold for a scale-out or a scale-in.<br>Each zonal group grows until it satisfies all the targets.<br><br>Additional optional attribute `type` defines the metric as either `GAUGE` (the default), `DELTA_PER_SECOND`, or `DELTA_PER_MINUTE`.<br>For full specification, see the `metric` inside the [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_autoscaler). | `map` | <pre>{<br>  "custom.googleapis.com/VMSeries/panSessionThroughputKbps": {<br>    "target": 700000<br>  },<br>  "custom.googleapis.com/VMSeries/panSessionUtilization": {<br>    "target": 70<br>  }<br>}</pre> | no |
| <a name="input_bootstrap_bucket"></a> [bootstrap\_bucket](#input\_bootstrap\_bucket) | n/a | `string` | `""` | no |
| <a name="input_cooldown_period"></a> [cooldown\_period](#input\_cooldown\_period) | How much tame does it take for a spawned PA-VM to become functional on the initialization boot | `number` | `720` | no |
| <a name="input_dependencies"></a> [dependencies](#input\_dependencies) | n/a | `list(string)` | `[]` | no |
| <a name="input_deployment_name"></a> [deployment\_name](#input\_deployment\_name) | Deployment Name that matches what is specified in Panorama GCP Plugin | `string` | n/a | yes |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | n/a | `string` | `"pd-ssd"` | no |
| <a name="input_image"></a> [image](#input\_image) | Link to VM-Series PAN-OS image. Can be either a full self\_link, or one of the shortened forms per the [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#image). | `string` | `"https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/vmseries-byol-912"` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | n/a | `string` | n/a | yes |
| <a name="input_max_replicas_per_zone"></a> [max\_replicas\_per\_zone](#input\_max\_replicas\_per\_zone) | Maximum number of VM-series instances per *each* of the zones | `number` | `1` | no |
| <a name="input_mgmt_interface_swap"></a> [mgmt\_interface\_swap](#input\_mgmt\_interface\_swap) | n/a | `string` | `""` | no |
| <a name="input_min_cpu_platform"></a> [min\_cpu\_platform](#input\_min\_cpu\_platform) | n/a | `string` | `"Intel Broadwell"` | no |
| <a name="input_min_replicas_per_zone"></a> [min\_replicas\_per\_zone](#input\_min\_replicas\_per\_zone) | Minimum number of VM-series instances per *each* of the zones | `number` | `1` | no |
| <a name="input_named_ports"></a> [named\_ports](#input\_named\_ports) | (Optional) The list of named ports:<pre>named_ports = [<br>  {<br>    name = "http"<br>    port = "80"<br>  },<br>  {<br>    name = "app42"<br>    port = "4242"<br>  },<br>]</pre>The name identifies the backend port to receive the traffic from the global load balancers. | `list` | `[]` | no |
| <a name="input_nic0_ip"></a> [nic0\_ip](#input\_nic0\_ip) | n/a | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_nic0_public_ip"></a> [nic0\_public\_ip](#input\_nic0\_public\_ip) | n/a | `bool` | `false` | no |
| <a name="input_nic1_ip"></a> [nic1\_ip](#input\_nic1\_ip) | n/a | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_nic1_public_ip"></a> [nic1\_public\_ip](#input\_nic1\_public\_ip) | n/a | `bool` | `false` | no |
| <a name="input_nic2_ip"></a> [nic2\_ip](#input\_nic2\_ip) | n/a | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_nic2_public_ip"></a> [nic2\_public\_ip](#input\_nic2\_public\_ip) | n/a | `bool` | `false` | no |
| <a name="input_pool"></a> [pool](#input\_pool) | The self\_link of google\_compute\_target\_pool where the auto-created instances will be placed for healtchecking of External Load Balancer | `string` | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to various GCP resource names | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP region to deploy to, if not set the default provider region is used. | `string` | `null` | no |
| <a name="input_scale_in_control_replicas_fixed"></a> [scale\_in\_control\_replicas\_fixed](#input\_scale\_in\_control\_replicas\_fixed) | Fixed number of VM instances that can be killed in each zone within the scale-in time window.<br>See `scale_in_control` in the [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_autoscaler). | `number` | `1` | no |
| <a name="input_scale_in_control_time_window_sec"></a> [scale\_in\_control\_time\_window\_sec](#input\_scale\_in\_control\_time\_window\_sec) | How many seconds autoscaling should look into the past when scaling in (down).<br>Default 30 minutes corresponds to the default custom metrics period of 5 minutes<br>and also to the considerable init time of a fresh instance. | `number` | `1800` | no |
| <a name="input_scopes"></a> [scopes](#input\_scopes) | n/a | `list(string)` | <pre>[<br>  "https://www.googleapis.com/auth/compute.readonly",<br>  "https://www.googleapis.com/auth/cloud.useraccounts.readonly",<br>  "https://www.googleapis.com/auth/devstorage.read_only",<br>  "https://www.googleapis.com/auth/logging.write",<br>  "https://www.googleapis.com/auth/monitoring.write"<br>]</pre> | no |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | IAM Service Account for running firewall instance (just the email) | `string` | `null` | no |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | n/a | `string` | `""` | no |
| <a name="input_subnetworks"></a> [subnetworks](#input\_subnetworks) | n/a | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `list(string)` | `[]` | no |
| <a name="input_update_policy_min_ready_sec"></a> [update\_policy\_min\_ready\_sec](#input\_update\_policy\_min\_ready\_sec) | After underlying template changes (e.g. PAN-OS upgrade) and the new instance is being spawned,<br>how long to wait after it becomes online.<br>See `update_policy` in the [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_group_manager)." | `number` | `720` | no |
| <a name="input_update_policy_type"></a> [update\_policy\_type](#input\_update\_policy\_type) | What to do when the underlying template changes (e.g. PAN-OS upgrade).<br>OPPORTUNISTIC is the only recommended value. Also PROACTIVE is allowed: it immediately<br>starts to re-create/delete instances and since this is not coordinated with<br>the instance group manager in other zone, it can easily lead to total outage.<br>It is thus feasible only in dev environments. Real environments should<br>perform a "Rolling Update" in GCP web interface. | `string` | `"OPPORTUNISTIC"` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | Map of zone names for the zonal IGMs | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backends"></a> [backends](#output\_backends) | Map of instance group (IG) identifiers, suitable for use in module lb\_tcp\_internal as input `backends`. |
| <a name="output_instance_group_manager"></a> [instance\_group\_manager](#output\_instance\_group\_manager) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
