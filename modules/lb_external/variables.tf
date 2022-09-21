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

variable "session_affinity" {
  description = "How to distribute load. Options are `NONE`, `CLIENT_IP` and `CLIENT_IP_PROTO`."
  type        = string
  default     = "NONE"
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

variable "instances" {
  description = "List of links to the instances. Expected to be empty when using an autoscaler, as the autoscaler inserts entries to the target pool dynamically. The nic0 of each instance gets the traffic. Even when this list is shifted or re-ordered, it doesn't re-create any resources and such modifications often proceed without any noticeable downtime."
  type        = list(string)
  default     = null
}

variable "connection_tracking_mode" {
  description = "There are two options: PER_CONNECTION: The Connection Tracking is performed as per the Connection Key (default Hash Method) for the specific protocol. PER_SESSION: The Connection Tracking is performed as per the configured Session Affinity. It matches the configured Session Affinity."
  type        = string
  default     = "PER_CONNECTION"
}

variable "connection_persistence_on_unhealthy_backends" {
  description = "Specifies connection persistence when backends are unhealthy. If set to DEFAULT_FOR_PROTOCOL, the existing connections persist on unhealthy backends only for connection-oriented protocols (TCP and SCTP) and only if the Tracking Mode is PER_CONNECTION (default tracking mode) or the Session Affinity is configured for 5-tuple. They do not persist for UDP. If set to NEVER_PERSIST, after a backend becomes unhealthy, the existing connections on the unhealthy backend are never persisted on the unhealthy backend. They are always diverted to newly selected healthy backends (unless all backends are unhealthy). If set to ALWAYS_PERSIST, existing connections always persist on unhealthy backends regardless of protocol and session affinity. It is generally not recommended to use this mode overriding the default."
  type        = string
  default     = "DEFAULT_FOR_PROTOCOL"
}

variable "idle_timeout_sec" {
  description = "Specifies how long to keep a Connection Tracking entry while there is no matching traffic (in seconds). For L4 ILB the minimum(default) is 10 minutes and maximum is 16 hours. For NLB the minimum(default) is 60 seconds and the maximum is 16 hours."
  type        = number
  default     = null
}

variable "network_tier" {
  description = "The networking tier used for configuring this address. If this field is not specified, it is assumed to be PREMIUM. Possible values are PREMIUM and STANDARD."
  type        = string
  default     = "PREMIUM"
}

variable "backend_instance_groups" {
  description = "List of backend instance groups"
  default     = []
}
