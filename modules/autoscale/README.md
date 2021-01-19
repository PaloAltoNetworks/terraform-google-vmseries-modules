# Auto-Scaling for Palo Alto Networks VM-Series

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

The following requirements are needed by this module:

- google (~> 3.48)

- null (~> 2.1)

- random (~> 2.3)

## Required Inputs

The following input variables are required:

### deployment\_name

Description: Deployment Name that matches what is specified in Panorama GCP Plugin

Type: `string`

### machine\_type

Description: n/a

Type: `string`

### prefix

Description: Prefix to various GCP resource names

Type: `string`

### subnetworks

Description: n/a

Type: `list(string)`

## Optional Inputs

The following input variables are optional (have default values):

### autoscaler\_metrics

Description: The map with the keys being metrics identifiers (e.g. custom.googleapis.com/VMSeries/panSessionUtilization).  
Each of the contained objects has attribute `target` which is a numerical threshold for a scale-out or a scale-in.  
Each zonal group grows until it satisfies all the targets.

Additional optional attribute `type` defines the metric as either `GAUGE` (the default), `DELTA_PER_SECOND`, or `DELTA_PER_MINUTE`.  
For full specification, see the `metric` inside the [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_autoscaler).

Type: `map`

Default:

```json
{
  "custom.googleapis.com/VMSeries/panSessionThroughputKbps": {
    "target": 700000
  },
  "custom.googleapis.com/VMSeries/panSessionUtilization": {
    "target": 70
  }
}
```

### bootstrap\_bucket

Description: n/a

Type: `string`

Default: `""`

### cooldown\_period

Description: How much tame does it take for a spawned PA-VM to become functional on the initialization boot

Type: `number`

Default: `720`

### dependencies

Description: n/a

Type: `list(string)`

Default: `[]`

### disk\_type

Description: n/a

Type: `string`

Default: `"pd-ssd"`

### image

Description: Link to VM-Series PAN-OS image. Can be either a full self\_link, or one of the shortened forms per the [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#image).

Type: `string`

Default: `"https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/vmseries-byol-912"`

### max\_replicas\_per\_zone

Description: Maximum number of VM-series instances per *each* of the zones

Type: `number`

Default: `1`

### mgmt\_interface\_swap

Description: n/a

Type: `string`

Default: `""`

### min\_cpu\_platform

Description: n/a

Type: `string`

Default: `"Intel Broadwell"`

### min\_replicas\_per\_zone

Description: Minimum number of VM-series instances per *each* of the zones

Type: `number`

Default: `1`

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

Type: `list`

Default: `[]`

### nic0\_ip

Description: n/a

Type: `list(string)`

Default:

```json
[
  ""
]
```

### nic0\_public\_ip

Description: n/a

Type: `bool`

Default: `false`

### nic1\_ip

Description: n/a

Type: `list(string)`

Default:

```json
[
  ""
]
```

### nic1\_public\_ip

Description: n/a

Type: `bool`

Default: `false`

### nic2\_ip

Description: n/a

Type: `list(string)`

Default:

```json
[
  ""
]
```

### nic2\_public\_ip

Description: n/a

Type: `bool`

Default: `false`

### pool

Description: The self\_link of google\_compute\_target\_pool where the auto-created instances will be placed for healtchecking of External Load Balancer

Type: `string`

Default: `null`

### region

Description: GCP region to deploy to, if not set the default provider region is used.

Type: `string`

Default: `null`

### scale\_in\_control\_replicas\_fixed

Description: Fixed number of VM instances that can be killed in each zone within the scale-in time window.  
See `scale_in_control` in the [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_autoscaler).

Type: `number`

Default: `1`

### scale\_in\_control\_time\_window\_sec

Description: How many seconds autoscaling should look into the past when scaling in (down).  
Default 30 minutes corresponds to the default custom metrics period of 5 minutes  
and also to the considerable init time of a fresh instance.

Type: `number`

Default: `1800`

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

### update\_policy\_min\_ready\_sec

Description: After underlying template changes (e.g. PAN-OS upgrade) and the new instance is being spawned,  
how long to wait after it becomes online.  
See `update_policy` in the [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_group_manager)."

Type: `number`

Default: `720`

### update\_policy\_type

Description: What to do when the underlying template changes (e.g. PAN-OS upgrade).  
OPPORTUNISTIC is the only recommended value. Also PROACTIVE is allowed: it immediately  
starts to re-create/delete instances and since this is not coordinated with  
the instance group manager in other zone, it can easily lead to total outage.  
It is thus feasible only in dev environments. Real environments should  
perform a "Rolling Update" in GCP web interface.

Type: `string`

Default: `"OPPORTUNISTIC"`

### zones

Description: Map of zone names for the zonal IGMs

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### backends

Description: Map of instance group (IG) identifiers, suitable for use in module lb\_tcp\_internal as input `backends`.

### instance\_group\_manager

Description: n/a

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
