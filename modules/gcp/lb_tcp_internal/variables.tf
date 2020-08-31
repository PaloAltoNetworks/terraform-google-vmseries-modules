variable name {
}

variable health_check_port {
  description = "Port number for TCP healthchecking."
  default     = 22
  type        = number
}

variable backends {
  description = "Map backend indices to list of backend maps."
  type = list(object({
    group    = string
    failover = bool
  }))
}

variable subnetwork {
  type = string
}

variable ip_address {
  default = null
}

variable ip_protocol {
  default = "TCP"
}
variable all_ports {
  type = bool
}
variable ports {
  description = "A single frontend port or a comma separated list of ports (up to 5 ports)."
  default     = []
  type        = list(string)
}

variable network {
  default = null
}
