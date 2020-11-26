# Palo Alto Networks VM-series firewall deployment

To manage via ssh/https please connect to the second interface (the `nic1`) of a VM-series firewall. The primary interface is by default not used for management.

When troubleshooting you can use this module also with a good ol' Linux image. Instead of booting PAN-OS, you can just re-create the same instance with Linux. It boots faster, it's probably more familiar, but there is a caveat when connecting from outside the GCP VPC Network:

- One cannot connect to `nic1` of Linux, because GCP DHCP doesn't ever furnish it with a default route. Connect to the primary interface (the `nic0`) for both data traffic and management traffic.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 3.30 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 3.30 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_address.private](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.public](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_instance.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_instance_group.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_group) | resource |
| [null_resource.dependency_getter](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [google_compute_subnetwork.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bootstrap_bucket"></a> [bootstrap\_bucket](#input\_bootstrap\_bucket) | n/a | `string` | `""` | no |
| <a name="input_create_instance_group"></a> [create\_instance\_group](#input\_create\_instance\_group) | n/a | `bool` | `false` | no |
| <a name="input_dependencies"></a> [dependencies](#input\_dependencies) | n/a | `list(string)` | `[]` | no |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | Default is pd-ssd, alternative is pd-balanced. | `string` | `"pd-ssd"` | no |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | The image name from which to boot an instance, including the license type and the version, e.g. vmseries-byol-814, vmseries-bundle1-814, vmseries-flex-bundle2-1001. Default is vmseries-flex-bundle1-913. | `string` | `"vmseries-flex-bundle1-913"` | no |
| <a name="input_image_prefix_uri"></a> [image\_prefix\_uri](#input\_image\_prefix\_uri) | The image URI prefix, by default https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/ string. When prepended to `image_name` it should result in a full valid Google Cloud Engine image resource URI. | `string` | `"https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/"` | no |
| <a name="input_image_uri"></a> [image\_uri](#input\_image\_uri) | The full URI to GCE image resource, the output of `gcloud compute images list --uri`. Overrides `image_name` and `image_prefix_uri` inputs. | `string` | `null` | no |
| <a name="input_instances"></a> [instances](#input\_instances) | Definition of firewalls that will be deployed | `map(any)` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | n/a | `map(any)` | `{}` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Firewall instance machine type, which depends on the license used. See the [Terraform manual](https://www.terraform.io/docs/providers/google/r/compute_instance.html) | `string` | `"n1-standard-4"` | no |
| <a name="input_metadata"></a> [metadata](#input\_metadata) | n/a | `map(string)` | `{}` | no |
| <a name="input_metadata_startup_script"></a> [metadata\_startup\_script](#input\_metadata\_startup\_script) | Ignored unless `nonprod_just_linux` is true. Intended for initial troubleshooting only, not for production use.<br>It is always executed using /bin/bash and the shebang line is ignored. | `string` | `null` | no |
| <a name="input_min_cpu_platform"></a> [min\_cpu\_platform](#input\_min\_cpu\_platform) | n/a | `string` | `"Intel Broadwell"` | no |
| <a name="input_named_ports"></a> [named\_ports](#input\_named\_ports) | (Optional) The list of named ports:<pre>named_ports = [<br>  {<br>    name = "http"<br>    port = "80"<br>  },<br>  {<br>    name = "app42"<br>    port = "4242"<br>  },<br>]</pre>The name identifies the backend port to receive the traffic from the global load balancers.<br>Practically, tcp port 80 named "http" works even when not defined here, but it's not a documented provider's behavior. | `list` | `[]` | no |
| <a name="input_nonprod_just_linux"></a> [nonprod\_just\_linux](#input\_nonprod\_just\_linux) | Deploy a plain Linux image instead of Palo Alto Networks VM-Series image.<br>Set Linux to ip\_forward all the traffic without any filtering.<br>Unsafe for any normal use, intended for initial troubleshooting of the connectivity. Only recommended on a *closed network*.<br><br>Bootstrap bucket or Panorama is not used/contacted at all with this setting.<br><br>The default image\_uri becomes "debian-cloud-testing/debian-sid", but still remains customizable. | `bool` | `false` | no |
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | `null` | no |
| <a name="input_resource_policies"></a> [resource\_policies](#input\_resource\_policies) | n/a | `list(string)` | `[]` | no |
| <a name="input_scopes"></a> [scopes](#input\_scopes) | n/a | `list(string)` | <pre>[<br>  "https://www.googleapis.com/auth/compute.readonly",<br>  "https://www.googleapis.com/auth/cloud.useraccounts.readonly",<br>  "https://www.googleapis.com/auth/devstorage.read_only",<br>  "https://www.googleapis.com/auth/logging.write",<br>  "https://www.googleapis.com/auth/monitoring.write"<br>]</pre> | no |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | IAM Service Account for running firewall instance (just the email) | `string` | `null` | no |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | n/a | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_group_self_links"></a> [instance\_group\_self\_links](#output\_instance\_group\_self\_links) | n/a |
| <a name="output_instance_groups"></a> [instance\_groups](#output\_instance\_groups) | n/a |
| <a name="output_instances"></a> [instances](#output\_instances) | n/a |
| <a name="output_names"></a> [names](#output\_names) | n/a |
| <a name="output_nic0_ips"></a> [nic0\_ips](#output\_nic0\_ips) | Map of IP addresses of interface at index 0, one entry per each instance. Contains public IP if one exists, otherwise private IP. |
| <a name="output_nic0_private_ips"></a> [nic0\_private\_ips](#output\_nic0\_private\_ips) | n/a |
| <a name="output_nic0_public_ips"></a> [nic0\_public\_ips](#output\_nic0\_public\_ips) | n/a |
| <a name="output_nic1_ips"></a> [nic1\_ips](#output\_nic1\_ips) | Map of IP addresses of interface at index 1, one entry per each instance. Contains public IP if one exists, otherwise private IP. |
| <a name="output_nic1_private_ips"></a> [nic1\_private\_ips](#output\_nic1\_private\_ips) | n/a |
| <a name="output_nic1_public_ips"></a> [nic1\_public\_ips](#output\_nic1\_public\_ips) | n/a |
| <a name="output_private_ips"></a> [private\_ips](#output\_private\_ips) | n/a |
| <a name="output_public_ips"></a> [public\_ips](#output\_public\_ips) | n/a |
| <a name="output_self_links"></a> [self\_links](#output\_self\_links) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->