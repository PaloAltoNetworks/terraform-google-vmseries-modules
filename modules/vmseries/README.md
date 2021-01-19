# Palo Alto Networks VM-series firewall deployment

To manage via ssh/https please connect to the second interface (the `nic1`) of a VM-series firewall. The primary interface is by default not used for management.

When troubleshooting you can use this module also with a good ol' Linux image. Instead of booting PAN-OS, you can just re-create the same instance with Linux. It boots faster, it's probably more familiar, but there is a caveat when connecting from outside the GCP VPC Network:

- One cannot connect to `nic1` of Linux, because GCP DHCP doesn't ever furnish it with a default route. Connect to the primary interface (the `nic0`) for both data traffic and management traffic.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

The following requirements are needed by this module:

- google (~> 3.30)

- null (~> 2.1)

## Required Inputs

The following input variables are required:

### instances

Description: Definition of firewalls that will be deployed

Type: `map(any)`

## Optional Inputs

The following input variables are optional (have default values):

### bootstrap\_bucket

Description: n/a

Type: `string`

Default: `""`

### create\_instance\_group

Description: n/a

Type: `bool`

Default: `false`

### dependencies

Description: n/a

Type: `list(string)`

Default: `[]`

### disk\_type

Description: Default is pd-ssd, alternative is pd-balanced.

Type: `string`

Default: `"pd-ssd"`

### image\_name

Description: The image name from which to boot an instance, including the license type and the version, e.g. vmseries-byol-814, vmseries-bundle1-814, vmseries-flex-bundle2-1001. Default is vmseries-flex-bundle1-913.

Type: `string`

Default: `"vmseries-flex-bundle1-913"`

### image\_prefix\_uri

Description: The image URI prefix, by default https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/ string. When prepended to `image_name` it should result in a full valid Google Cloud Engine image resource URI.

Type: `string`

Default: `"https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/"`

### image\_uri

Description: The full URI to GCE image resource, the output of `gcloud compute images list --uri`. Overrides `image_name` and `image_prefix_uri` inputs.

Type: `string`

Default: `null`

### labels

Description: n/a

Type: `map(any)`

Default: `{}`

### machine\_type

Description: Firewall instance machine type, which depends on the license used. See the [Terraform manual](https://www.terraform.io/docs/providers/google/r/compute_instance.html)

Type: `string`

Default: `"n1-standard-4"`

### metadata

Description: n/a

Type: `map(string)`

Default: `{}`

### metadata\_startup\_script

Description: See the [Terraform manual](https://www.terraform.io/docs/providers/google/r/compute_instance.html)

Type: `string`

Default: `null`

### min\_cpu\_platform

Description: n/a

Type: `string`

Default: `"Intel Broadwell"`

### named\_ports

Description: (Optional) The list of named ports:

```
named_ports = [
  {
    name = "http"
    port = "80"
  },
  {
    name = "app42"
    port = "4242"
  },
]
```

The name identifies the backend port to receive the traffic from the global load balancers.  
Practically, tcp port 80 named "http" works even when not defined here, but it's not a documented provider's behavior.

Type: `list`

Default: `[]`

### project

Description: n/a

Type: `string`

Default: `null`

### resource\_policies

Description: n/a

Type: `list(string)`

Default: `[]`

### scopes

Description: n/a

Type: `list(string)`

Default:

```json
[
  "https://www.googleapis.com/auth/compute.readonly",
  "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
  "https://www.googleapis.com/auth/devstorage.read_only",
  "https://www.googleapis.com/auth/logging.write",
  "https://www.googleapis.com/auth/monitoring.write"
]
```

### service\_account

Description: IAM Service Account for running firewall instance (just the email)

Type: `string`

Default: `null`

### ssh\_key

Description: n/a

Type: `string`

Default: `""`

### tags

Description: n/a

Type: `list(string)`

Default: `[]`

## Outputs

The following outputs are exported:

### instance\_group\_self\_links

Description: n/a

### instance\_groups

Description: n/a

### instances

Description: n/a

### names

Description: n/a

### nic0\_ips

Description: Map of IP addresses of interface at index 0, one entry per each instance. Contains public IP if one exists, otherwise private IP.

### nic0\_private\_ips

Description: n/a

### nic0\_public\_ips

Description: n/a

### nic1\_ips

Description: Map of IP addresses of interface at index 1, one entry per each instance. Contains public IP if one exists, otherwise private IP.

### nic1\_private\_ips

Description: n/a

### nic1\_public\_ips

Description: n/a

### private\_ips

Description: n/a

### public\_ips

Description: n/a

### self\_links

Description: n/a

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->