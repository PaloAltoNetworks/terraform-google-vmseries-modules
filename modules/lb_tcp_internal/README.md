# Internally-Facing Regional TCP/UDP Load Balancer on GCP

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

The following requirements are needed by this module:

- google (~> 3.30)

## Required Inputs

The following input variables are required:

### backends

Description: Names of primary backend groups (IGs or IGMs). Typically use `module.vmseries.instance_group_self_links` here.

Type: `map(string)`

### name

Description: Name of the load balancer (that is, both the forwarding rule and the backend service)

Type: `string`

### subnetwork

Description: n/a

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### all\_ports

Description: Forward all ports of the ip\_protocol from the frontend to the backends. Needs to be null if `ports` are provided.

Type: `bool`

Default: `null`

### allow\_global\_access

Description: (Optional) If true, clients can access ILB from all regions. By default false, only allow from the ILB's local region; useful if the ILB is a next hop of a route.

Type: `bool`

Default: `false`

### disable\_connection\_drain\_on\_failover

Description: (Optional) On failover or failback, this field indicates whether connection drain will be honored. Setting this to true has the following effect: connections to the old active pool are not drained. Connections to the new active pool use the timeout of 10 min (currently fixed). Setting to false has the following effect: both old and new connections will have a drain timeout of 10 min. This can be set to true only if the protocol is TCP. The default is false.

Type: `bool`

Default: `null`

### drop\_traffic\_if\_unhealthy

Description: (Optional) Used only when no healthy VMs are detected in the primary and backup instance groups. When set to true, traffic is dropped. When set to false, new connections are sent across all VMs in the primary group. The default is false.

Type: `bool`

Default: `null`

### failover\_backends

Description: (Optional) Names of failover backend groups (IGs or IGMs). Failover groups are ignored unless the primary groups do not meet collective health threshold.

Type: `map(string)`

Default: `{}`

### failover\_ratio

Description: (Optional) The value of the field must be in [0, 1]. If the ratio of the healthy VMs in the primary backend is at or below this number, traffic arriving at the load-balanced IP will be directed to the failover\_backends. In case where 'failoverRatio' is not set or all the VMs in the backup backend are unhealthy, the traffic will be directed back to the primary backend in the `force` mode, where traffic will be spread to the healthy VMs with the best effort, or to all VMs when no VM is healthy. This field is only used with l4 load balancing.

Type: `number`

Default: `null`

### health\_check

Description: (Optional) Name of either the global google\_compute\_health\_check or google\_compute\_region\_health\_check to use. Conflicts with health\_check\_port.

Type: `string`

Default: `null`

### health\_check\_port

Description: (Optional) Port number for TCP healthchecking, default 22. This setting is ignored when `health_check` is provided.

Type: `number`

Default: `22`

### ip\_address

Description: n/a

Type: `any`

Default: `null`

### ip\_protocol

Description: n/a

Type: `string`

Default: `"TCP"`

### network

Description: n/a

Type: `any`

Default: `null`

### ports

Description: Which port numbers are forwarded to the backends (up to 5 ports). Conflicts with all\_ports.

Type: `list(number)`

Default: `[]`

### session\_affinity

Description: (Optional, TCP only) Try to direct sessions to the same backend, can be: CLIENT\_IP, CLIENT\_IP\_PORT\_PROTO, CLIENT\_IP\_PROTO, NONE (default is NONE).

Type: `string`

Default: `null`

### timeout\_sec

Description: (Optional) How many seconds to wait for the backend before dropping the connection. Default is 30 seconds. Valid range is [1, 86400].

Type: `number`

Default: `null`

## Outputs

The following outputs are exported:

### address

Description: n/a

### forwarding\_rule

Description: n/a

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
