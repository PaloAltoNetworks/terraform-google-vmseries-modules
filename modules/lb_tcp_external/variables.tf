
variable project {
  type        = string
  description = "The project to deploy to. If unset the default provider project is used."
  default     = ""
}

variable region {
  description = "GCP region to deploy to. If unset the default provider region is used."
  default     = null
  type        = string
}

variable name {
  description = "Name of the target pool and of the associated healthcheck."
  type        = string
}

variable rules {
  description = <<-EOF
  Map of objects, the keys are names of the external forwarding rules, each of the objects has the following attributes:

  - `port_ranges`: (Required) The port your service is listening on. Can be a number (80) or a range (8080-8089, or even 1-65535).
  - `ip_address`: (Optional) A public IP address on which to listen, must be in the same region as the LB and must be IPv4. If empty, automatically generates a new non-ephemeral IP on a PREMIUM tier.
  - `ip_protocol`: (Optional) The IP protocol for the frontend forwarding rule: TCP, UDP, ESP, or ICMP. Default is TCP.
  EOF
}

variable session_affinity {
  description = "How to distribute load. Options are `NONE`, `CLIENT_IP` and `CLIENT_IP_PROTO`."
  default     = "NONE"
  type        = string
}

variable create_health_check {
  description = "Whether to create a health check on the target pool."
  default     = true
  type        = bool
}

variable health_check_interval_sec {
  description = "Health check parameter, see [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check)"
  default     = null
  type        = number
}

variable health_check_healthy_threshold {
  description = "Health check parameter, see [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check)"
  default     = null
  type        = number
}

variable health_check_timeout_sec {
  description = "Health check parameter, see [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check)"
  default     = null
  type        = number
}

variable health_check_unhealthy_threshold {
  description = "Health check parameter, see [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check)"
  default     = null
  type        = number
}

variable health_check_http_port {
  description = "Health check parameter, see [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check)"
  default     = null
  type        = number
}

variable health_check_http_request_path {
  description = "Health check http request path, with the default adjusted to /php/login.php to be able to check the health of the PAN-OS webui."
  default     = "/php/login.php"
  type        = string
}

variable health_check_http_host {
  description = "Health check http request host header, with the default adjusted to localhost to be able to check the health of the PAN-OS webui."
  default     = "localhost"
  type        = string
}

variable instances {
  description = "List of links to the instances. Expected to be empty when using an autoscaler, as the autoscaler inserts entries to the target pool dynamically. The nic0 of each instance gets the traffic. Even when this list is shifted or re-ordered, it doesn't re-create any resources and such modifications often proceed without any noticeable downtime."
  default     = null
  type        = list(string)
}
