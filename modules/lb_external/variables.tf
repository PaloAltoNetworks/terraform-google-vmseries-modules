variable "project" {
  description = "The project to deploy to. If unset the default provider project is used."
  type        = string
  default     = ""
}

variable "region" {
  description = "GCP region to deploy to. If unset the default provider region is used."
  type        = string
  default     = null
}

variable "name" {
  description = "Name of the backend_service, target_pool and of the associated health check."
  type        = string
}

variable "rules" {
  description = <<-EOF
  Map of objects, the keys are names of the external forwarding rules, each of the objects has the following attributes:

  - `port_range`: (Required) The port your service is listening on. Can be a number (80) or a range (8080-8089, or even 1-65535).
  - `ip_address`: (Optional) A public IP address on which to listen, must be in the same region as the LB and must be IPv4. If empty, automatically generates a new non-ephemeral IP on a PREMIUM tier.
  - `ip_protocol`: (Optional) The IP protocol for the frontend forwarding rule: TCP, UDP, ESP, ICMP, or L3_DEFAULT. Default is TCP.
  - `all_ports`: (Optional) Allows all ports to be forwarded to the Backend Service

  EOF
}

variable "instances" {
  description = "List of links to the instances. Expected to be empty when using an autoscaler, as the autoscaler inserts entries to the target pool dynamically. The nic0 of each instance gets the traffic. Even when this list is shifted or re-ordered, it doesn't re-create any resources and such modifications often proceed without any noticeable downtime."
  type        = list(string)
  default     = null
}

variable "backend_instance_groups" {
  description = "List of backend instance groups"
  default     = []
}

variable "session_affinity" {
  description = <<-EOF
  Controls distribution of new connections (or fragmented UDP packets) from clients to the backends, can influence available connection tracking configurations.
  Valid values are: NONE (default), CLIENT_IP, CLIENT_IP_PROTO, CLIENT_IP_PORT_PROTO (only available for backend service based rules).
  EOF
  type        = string
  default     = "NONE"
}

variable "connection_tracking_policy" {
  description = <<-EOF
  Connection tracking policy settings, only available for backend service based rules. Following options are available:
  - `mode`                              - (Optional|string) `PER_CONNECTION` (default) or `PER_SESSION`
  - `persistence_on_unhealthy_backends` - (Optional|string) `DEFAULT_FOR_PROTOCOL` (default), `ALWAYS_PERSIST` or `NEVER_PERSIST`

  More information about supported configurations in conjunction with `session_affinity` is available in [Backend service-based external Network Load Balancing](https://cloud.google.com/load-balancing/docs/network/networklb-backend-service#connection-tracking) documentation.
  EOF
  default     = null
  type        = map(any)
}

variable "network_tier" {
  description = "The networking tier used for configuring this address. If this field is not specified, it is assumed to be PREMIUM. Possible values are PREMIUM and STANDARD."
  type        = string
  default     = "PREMIUM"
}

variable "create_health_check" {
  description = "Whether to create a health check on the target pool."
  type        = bool
  default     = true
}

variable "health_check_interval_sec" {
  description = "Health check parameter, see [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check)"
  type        = number
  default     = null
}

variable "health_check_healthy_threshold" {
  description = "Health check parameter, see [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check)"
  type        = number
  default     = null
}

variable "health_check_timeout_sec" {
  description = "Health check parameter, see [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check)"
  type        = number
  default     = null
}

variable "health_check_unhealthy_threshold" {
  description = "Health check parameter, see [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check)"
  type        = number
  default     = null
}

variable "health_check_http_port" {
  description = "Health check parameter, see [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check)"
  type        = number
  default     = null
}

variable "health_check_http_request_path" {
  description = "Health check http request path, with the default adjusted to /php/login.php to be able to check the health of the PAN-OS webui."
  type        = string
  default     = "/php/login.php"
}

variable "health_check_http_host" {
  description = "Health check http request host header, with the default adjusted to localhost to be able to check the health of the PAN-OS webui."
  type        = string
  default     = "localhost"
}
