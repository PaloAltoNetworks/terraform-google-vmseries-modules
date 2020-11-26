# Palo Alto Networks VM-series firewall deployment

To manage via ssh/https please connect to the second interface (the `nic1`) of a VM-series firewall. The primary interface is by default not used for management.

When troubleshooting you can use this module also with a good ol' Linux image. Instead of booting PAN-OS, you can just re-create the same instance with Linux. It boots faster, it's probably more familiar, but there is a caveat when connecting from outside the GCP VPC Network:

- One cannot connect to `nic1` of Linux, because GCP DHCP doesn't ever furnish it with a default route. Connect to the primary interface (the `nic0`) for both data traffic and management traffic.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| google | ~> 3.30 |
| null | ~> 2.1 |

## Providers

| Name | Version |
|------|---------|
| google | ~> 3.30 |
| null | ~> 2.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bootstrap\_bucket | n/a | `string` | `""` | no |
| create\_instance\_group | n/a | `bool` | `false` | no |
| dependencies | n/a | `list(string)` | `[]` | no |
| disk\_type | Default is pd-ssd, alternative is pd-balanced. | `string` | `"pd-ssd"` | no |
| image\_name | The image name from which to boot an instance, including the license type and the version, e.g. vmseries-byol-814, vmseries-bundle1-814, vmseries-flex-bundle2-1001. Default is vmseries-flex-bundle1-913. | `string` | `"vmseries-flex-bundle1-913"` | no |
| image\_prefix\_uri | The image URI prefix, by default https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/ string. When prepended to `image_name` it should result in a full valid Google Cloud Engine image resource URI. | `string` | `"https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/"` | no |
| image\_uri | The full URI to GCE image resource, the output of `gcloud compute images list --uri`. Overrides `image_name` and `image_prefix_uri` inputs. | `string` | `null` | no |
| instances | Definition of firewalls that will be deployed | `map(any)` | n/a | yes |
| labels | n/a | `map(any)` | `{}` | no |
| machine\_type | Firewall instance machine type, which depends on the license used. See the [Terraform manual](https://www.terraform.io/docs/providers/google/r/compute_instance.html) | `string` | `"n1-standard-4"` | no |
| metadata | n/a | `map(string)` | `{}` | no |
| metadata\_startup\_script | Ignored unless `nonprod_just_linux` is true. Intended for initial troubleshooting only, not for production use.<br>It is always executed using /bin/bash and the shebang line is ignored. | `string` | `null` | no |
| min\_cpu\_platform | n/a | `string` | `"Intel Broadwell"` | no |
| named\_ports | (Optional) The list of named ports:<pre>named_ports = [<br>  {<br>    name = "http"<br>    port = "80"<br>  },<br>  {<br>    name = "app42"<br>    port = "4242"<br>  },<br>]</pre>The name identifies the backend port to receive the traffic from the global load balancers.<br>Practically, tcp port 80 named "http" works even when not defined here, but it's not a documented provider's behavior. | `list` | `[]` | no |
| nonprod\_just\_linux | Deploy a plain Linux image instead of Palo Alto Networks VM-Series image.<br>Set Linux to ip\_forward all the traffic without any filtering.<br>Unsafe for any normal use, intended for initial troubleshooting of the connectivity. Only recommended on a \*closed network\*.<br><br>Bootstrap bucket or Panorama is not used/contacted at all with this setting.<br><br>The default image\_uri becomes "debian-cloud-testing/debian-sid", but still remains customizable. | `bool` | `false` | no |
| project | n/a | `string` | `null` | no |
| resource\_policies | n/a | `list(string)` | `[]` | no |
| scopes | n/a | `list(string)` | <pre>[<br>  "https://www.googleapis.com/auth/compute.readonly",<br>  "https://www.googleapis.com/auth/cloud.useraccounts.readonly",<br>  "https://www.googleapis.com/auth/devstorage.read_only",<br>  "https://www.googleapis.com/auth/logging.write",<br>  "https://www.googleapis.com/auth/monitoring.write"<br>]</pre> | no |
| service\_account | IAM Service Account for running firewall instance (just the email) | `string` | `null` | no |
| ssh\_key | n/a | `string` | `""` | no |
| tags | n/a | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance\_group\_self\_links | n/a |
| instance\_groups | n/a |
| instances | n/a |
| names | n/a |
| nic0\_ips | Map of IP addresses of interface at index 0, one entry per each instance. Contains public IP if one exists, otherwise private IP. |
| nic0\_private\_ips | n/a |
| nic0\_public\_ips | n/a |
| nic1\_ips | Map of IP addresses of interface at index 1, one entry per each instance. Contains public IP if one exists, otherwise private IP. |
| nic1\_private\_ips | n/a |
| nic1\_public\_ips | n/a |
| private\_ips | n/a |
| public\_ips | n/a |
| self\_links | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->