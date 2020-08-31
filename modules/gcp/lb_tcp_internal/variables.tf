variable name {
}

variable health_check_port {
  description = "Port number for TCP healthchecking."
  default     = 22
  type        = number
}

variable backends {
  description = "Names of primary backend groups (IGs or IGMs)."
  type        = list(string)
}

variable failover_backends {
  description = "Names of failover backend groups (IGs or IGMs). Failover groups are ignored unless the primary groups do not meet collective health threshold."
  default     = []
  type        = list(string)
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
  description = "Load balance all ports of the ip_protocol. Needs to be null if ports are set."
  default     = null
  type        = bool
}
variable ports {
  description = "A single frontend port or a comma separated list of ports (up to 5 ports)."
  default     = []
  type        = list(string)
}

variable network {
  default = null
}

variable disable_connection_drain_on_failover {
  description = "(Optional) On failover or failback, this field indicates whether connection drain will be honored. Setting this to true has the following effect: connections to the old active pool are not drained. Connections to the new active pool use the timeout of 10 min (currently fixed). Setting to false has the following effect: both old and new connections will have a drain timeout of 10 min. This can be set to true only if the protocol is TCP. The default is false."
  default     = null
  type        = bool
}

variable drop_traffic_if_unhealthy {
  description = "(Optional) Used only when no healthy VMs are detected in the primary and backup instance groups. When set to true, traffic is dropped. When set to false, new connections are sent across all VMs in the primary group. The default is false."
  default     = false
  type        = bool
}

variable failover_ratio {
  description = "(Optional) The value of the field must be in [0, 1]. If the ratio of the healthy VMs in the primary backend is at or below this number, traffic arriving at the load-balanced IP will be directed to the failover_backends. In case where 'failoverRatio' is not set or all the VMs in the backup backend are unhealthy, the traffic will be directed back to the primary backend in the `force` mode, where traffic will be spread to the healthy VMs with the best effort, or to all VMs when no VM is healthy. This field is only used with l4 load balancing."
  default     = null
  type        = number
}
