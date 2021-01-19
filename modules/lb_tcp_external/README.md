# Externally-Facing Regional TCP/UDP Network Load Balancer on GCP

- A regional LB, which is faster than a global one.
- IPv4 only, a limitation imposed by GCP.
- Perhaps unexpectedly, the External TCP/UDP NLB has additional limitations imposed by GCP when comparing to the Internal TCP/UDP NLB, namely:

  - Despite it works for any TCP traffic (also UDP and other protocols), it can only use a plain HTTP health check. So, HTTPS or SSH probes are *not* possible.
  - Can only use the nic0 (the base interface) of an instance.
  - Cannot serve as a next hop in a GCP custom routing table entry.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

The following requirements are needed by this module:

- google (~> 3.30)

## Required Inputs

The following input variables are required:

### name

Description: Name of the target pool and of the associated healthcheck.

Type: `string`

### rules

Description: Map of objects, the keys are names of the external forwarding rules, each of the objects has the following attributes:

- `port_ranges`: (Required) The port your service is listening on. Can be a number (80) or a range (8080-8089, or even 1-65535).
- `ip_address`: (Optional) A public IP address on which to listen, must be in the same region as the LB and must be IPv4. If empty, automatically generates a new non-ephemeral IP on a PREMIUM tier.
- `ip_protocol`: (Optional) The IP protocol for the frontend forwarding rule: TCP, UDP, ESP, or ICMP. Default is TCP.

Type: `any`

## Optional Inputs

The following input variables are optional (have default values):

### create\_health\_check

Description: Whether to create a health check on the target pool.

Type: `bool`

Default: `true`

### health\_check\_healthy\_threshold

Description: Health check parameter, see [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check)

Type: `number`

Default: `null`

### health\_check\_http\_host

Description: Health check http request host header, with the default adjusted to localhost to be able to check the health of the PAN-OS webui.

Type: `string`

Default: `"localhost"`

### health\_check\_http\_port

Description: Health check parameter, see [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check)

Type: `number`

Default: `null`

### health\_check\_http\_request\_path

Description: Health check http request path, with the default adjusted to /php/login.php to be able to check the health of the PAN-OS webui.

Type: `string`

Default: `"/php/login.php"`

### health\_check\_interval\_sec

Description: Health check parameter, see [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check)

Type: `number`

Default: `null`

### health\_check\_timeout\_sec

Description: Health check parameter, see [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check)

Type: `number`

Default: `null`

### health\_check\_unhealthy\_threshold

Description: Health check parameter, see [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check)

Type: `number`

Default: `null`

### instances

Description: List of links to the instances. Expected to be empty when using an autoscaler, as the autoscaler inserts entries to the target pool dynamically. The nic0 of each instance gets the traffic. Even when this list is shifted or re-ordered, it doesn't re-create any resources and such modifications often proceed without any noticeable downtime.

Type: `list(string)`

Default: `null`

### project

Description: The project to deploy to. If unset the default provider project is used.

Type: `string`

Default: `""`

### region

Description: GCP region to deploy to. If unset the default provider region is used.

Type: `string`

Default: `null`

### session\_affinity

Description: How to distribute load. Options are `NONE`, `CLIENT_IP` and `CLIENT_IP_PROTO`.

Type: `string`

Default: `"NONE"`

## Outputs

The following outputs are exported:

### created\_health\_check

Description: The created health check resource. Null if `create_health_check` option was false.

### forwarding\_rules

Description: The map of created forwarding rules.

### ip\_addresses

Description: The map of IP addresses of the forwarding rules.

### target\_pool

Description: The self-link of the target pool.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Resources Created

- One TargetPool.
- Zero or one HttpHealthCheck, the legacy kind.
- Multiple ForwardingRules (all in a single region) of type EXTERNAL and tier PREMIUM.
  - Each creates zero or one of non-ephemeral, external, regional IPv4 IPAddresses.
