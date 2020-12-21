# Externally-Facing Regional TCP/UDP Network Load Balancer on GCP

- A regional LB, which is faster than a global one.
- IPv4 only, a limitation imposed by GCP.
- Perhaps unexpectedly, the External TCP/UDP NLB has additional limitations imposed by GCP when comparing to the Internal TCP/UDP NLB, namely:

  - Despite it works for any TCP traffic (also UDP and other protocols), it can only use a plain HTTP health check. So, HTTPS or SSH probes are *not* possible.
  - Can only use the nic0 (the base interface) of an instance.
  - Cannot serve as a next hop in a GCP custom routing table entry.

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
| disable\_health\_check | Disables the health check on the target pool. | `bool` | `false` | no |
| health\_check\_healthy\_threshold | Health check parameter, see [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check) | `number` | `null` | no |
| health\_check\_host | Health check http request host header, with the default adjusted to localhost to be able to check the health of the PAN-OS webui. | `string` | `"localhost"` | no |
| health\_check\_interval\_sec | Health check parameter, see [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check) | `number` | `null` | no |
| health\_check\_port | Health check parameter, see [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check) | `number` | `null` | no |
| health\_check\_request\_path | Health check http request path, with the default adjusted to /php/login.php to be able to check the health of the PAN-OS webui. | `string` | `"/php/login.php"` | no |
| health\_check\_timeout\_sec | Health check parameter, see [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check) | `number` | `null` | no |
| health\_check\_unhealthy\_threshold | Health check parameter, see [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check) | `number` | `null` | no |
| instances | Links to the instances (nic0 of each instance gets the traffic). Even when this list is shifted or re-ordered, it doesn't cause re-create and such modifications often proceed without any noticeable downtime. | `list(string)` | `null` | no |
| name | Name of the target pool and of the associated healthcheck. | `string` | n/a | yes |
| project | The project to deploy to, if not set the default provider project is used. | `string` | `""` | no |
| region | GCP region to deploy to, if not set the default provider region is used. | `string` | `null` | no |
| rules | Map of objects, the keys are names of the external forwarding rules, each object has the following attributes:<br><br>- port\_ranges: (Required) the port your service is listening on. Can be a number or a range like 8080-8089 or even 1-65535.<br>- ip\_address: (Optional) IP address of the external load balancer, auto-assigned if empty.<br>- ip\_protocol: (Optional) The IP protocol for the frontend forwarding rule: TCP, UDP, ESP, AH, SCTP or ICMP. Default is TCP. | `any` | n/a | yes |
| session\_affinity | How to distribute load. Options are `NONE`, `CLIENT_IP` and `CLIENT_IP_PROTO` | `string` | `"NONE"` | no |

## Outputs

| Name | Description |
|------|-------------|
| address | The map of IP addresses of the forwarding rules. |
| forwarding\_rules | The map of created forwarding rules. |
| target\_pool | The self-link of the target pool. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Resources Created

- One TargetPool.
- Zero or one HttpHealthCheck, the legacy kind.
- Multiple ForwardingRules (all in a single region) of type EXTERNAL and tier PREMIUM.
  - Each creates zero or one of non-ephemeral, external, regional IPv4 IPAddresses.
