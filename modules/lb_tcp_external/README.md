# Externally-Facing Regional TCP/UDP Load Balancer on GCP

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
| health\_check | Health check to determine whether instances are responsive and able to do work | <pre>object({<br>    check_interval_sec  = number<br>    healthy_threshold   = number<br>    timeout_sec         = number<br>    unhealthy_threshold = number<br>    port                = number<br>    request_path        = string<br>    host                = string<br>  })</pre> | <pre>{<br>  "check_interval_sec": null,<br>  "healthy_threshold": null,<br>  "host": null,<br>  "port": null,<br>  "request_path": null,<br>  "timeout_sec": null,<br>  "unhealthy_threshold": null<br>}</pre> | no |
| instances | Links to the instances (nic0 of each instance gets the traffic). Even when this list is shifted or re-ordered, it doesn't cause re-create and such modifications often proceed without any noticeable downtime. | `list(string)` | `null` | no |
| ip\_address | IP address of the external load balancer, if empty one will be assigned. | `any` | `null` | no |
| ip\_protocol | The IP protocol for the frontend forwarding rule: TCP, UDP, ESP, AH, SCTP or ICMP. | `string` | `"TCP"` | no |
| name | Name for the forwarding rule and prefix for supporting resources. | `string` | n/a | yes |
| project | The project to deploy to, if not set the default provider project is used. | `string` | `""` | no |
| region | GCP region to deploy to, if not set the default provider region is used. | `string` | `null` | no |
| service\_port | TCP port your service is listening on. Can be a number or a range like 8080-8089. | `any` | n/a | yes |
| session\_affinity | How to distribute load. Options are `NONE`, `CLIENT_IP` and `CLIENT_IP_PROTO` | `string` | `"NONE"` | no |

## Outputs

| Name | Description |
|------|-------------|
| address | The IP address of the forwarding rule. |
| forwarding\_rule | The self-link of the forwarding rule. |
| target\_pool | The self-link of the target pool. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
