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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.3, < 2.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 3.30 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 3.30 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_address.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_forwarding_rule.rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_http_health_check.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check) | resource |
| [google_compute_target_pool.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_pool) | resource |
| [google_client_config.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_health_check"></a> [create\_health\_check](#input\_create\_health\_check) | Whether to create a health check on the target pool. | `bool` | `true` | no |
| <a name="input_health_check_healthy_threshold"></a> [health\_check\_healthy\_threshold](#input\_health\_check\_healthy\_threshold) | Health check parameter, see [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check) | `number` | `null` | no |
| <a name="input_health_check_http_host"></a> [health\_check\_http\_host](#input\_health\_check\_http\_host) | Health check http request host header, with the default adjusted to localhost to be able to check the health of the PAN-OS webui. | `string` | `"localhost"` | no |
| <a name="input_health_check_http_port"></a> [health\_check\_http\_port](#input\_health\_check\_http\_port) | Health check parameter, see [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check) | `number` | `null` | no |
| <a name="input_health_check_http_request_path"></a> [health\_check\_http\_request\_path](#input\_health\_check\_http\_request\_path) | Health check http request path, with the default adjusted to /php/login.php to be able to check the health of the PAN-OS webui. | `string` | `"/php/login.php"` | no |
| <a name="input_health_check_interval_sec"></a> [health\_check\_interval\_sec](#input\_health\_check\_interval\_sec) | Health check parameter, see [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check) | `number` | `null` | no |
| <a name="input_health_check_timeout_sec"></a> [health\_check\_timeout\_sec](#input\_health\_check\_timeout\_sec) | Health check parameter, see [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check) | `number` | `null` | no |
| <a name="input_health_check_unhealthy_threshold"></a> [health\_check\_unhealthy\_threshold](#input\_health\_check\_unhealthy\_threshold) | Health check parameter, see [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check) | `number` | `null` | no |
| <a name="input_instances"></a> [instances](#input\_instances) | List of links to the instances. Expected to be empty when using an autoscaler, as the autoscaler inserts entries to the target pool dynamically. The nic0 of each instance gets the traffic. Even when this list is shifted or re-ordered, it doesn't re-create any resources and such modifications often proceed without any noticeable downtime. | `list(string)` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the target pool and of the associated healthcheck. | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | The project to deploy to. If unset the default provider project is used. | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | GCP region to deploy to. If unset the default provider region is used. | `string` | `null` | no |
| <a name="input_rules"></a> [rules](#input\_rules) | Map of objects, the keys are names of the external forwarding rules, each of the objects has the following attributes:<br><br>- `port_ranges`: (Required) The port your service is listening on. Can be a number (80) or a range (8080-8089, or even 1-65535).<br>- `ip_address`: (Optional) A public IP address on which to listen, must be in the same region as the LB and must be IPv4. If empty, automatically generates a new non-ephemeral IP on a PREMIUM tier.<br>- `ip_protocol`: (Optional) The IP protocol for the frontend forwarding rule: TCP, UDP, ESP, or ICMP. Default is TCP. | `any` | n/a | yes |
| <a name="input_session_affinity"></a> [session\_affinity](#input\_session\_affinity) | How to distribute load. Options are `NONE`, `CLIENT_IP` and `CLIENT_IP_PROTO`. | `string` | `"NONE"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_created_health_check"></a> [created\_health\_check](#output\_created\_health\_check) | The created health check resource. Null if `create_health_check` option was false. |
| <a name="output_forwarding_rules"></a> [forwarding\_rules](#output\_forwarding\_rules) | The map of created forwarding rules. |
| <a name="output_ip_addresses"></a> [ip\_addresses](#output\_ip\_addresses) | The map of IP addresses of the forwarding rules. |
| <a name="output_target_pool"></a> [target\_pool](#output\_target\_pool) | The self-link of the target pool. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Resources Created

- One TargetPool.
- Zero or one HttpHealthCheck, the legacy kind.
- Multiple ForwardingRules (all in a single region) of type EXTERNAL and tier PREMIUM.
  - Each creates zero or one of non-ephemeral, external, regional IPv4 IPAddresses.
