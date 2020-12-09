
variable project {
  type        = string
  description = "The project to deploy to, if not set the default provider project is used."
  default     = ""
}

variable region {
  description = "GCP region to deploy to, if not set the default provider region is used."
  default     = null
  type        = string
}

variable name {
  description = "Name of the target pool and of the associated healthcheck."
  type        = string
}

variable rules {
  description = <<-EOF
  Map of objects, the keys are names of the external forwarding rules, each object has the following attributes:

  - port_ranges: (Required) the port your service is listening on. Can be a number or a range like 8080-8089 or even 1-65535.
  - ip_address: (Optional) IP address of the external load balancer, auto-assigned if empty.
  - ip_protocol: (Optional) The IP protocol for the frontend forwarding rule: TCP, UDP, ESP, AH, SCTP or ICMP. Default is TCP.
  EOF
}

variable session_affinity {
  type        = string
  description = "How to distribute load. Options are `NONE`, `CLIENT_IP` and `CLIENT_IP_PROTO`"
  default     = "NONE"
}

variable disable_health_check {
  type        = bool
  description = "Disables the health check on the target pool."
  default     = false
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

variable health_check_port {
  description = "Health check parameter, see [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check)"
  default     = null
  type        = number
}

variable health_check_request_path {
  description = "Health check http request path, with the default adjusted to /php/login.php to be able to check the health of the PAN-OS webui."
  default     = "/php/login.php"
  type        = string
}

variable health_check_host {
  description = "Health check http request host header, with the default adjusted to localhost to be able to check the health of the PAN-OS webui."
  default     = "localhost"
  type        = string
}

variable instances {
  description = "Links to the instances (nic0 of each instance gets the traffic). Even when this list is shifted or re-ordered, it doesn't cause re-create and such modifications often proceed without any noticeable downtime."
  default     = null
  type        = list(string)
}
