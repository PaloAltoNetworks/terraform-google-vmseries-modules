variable name {
  description = "Name of the load balancer (that is, both the forwarding rule and the backend service)"
  type        = string
}

variable health_check_port {
  description = "(Optional) Port number for TCP healthchecking, default 22. This setting is ignored when `health_check` is provided."
  default     = 22
  type        = number
}

variable health_check {
  description = "(Optional) Name of either the global google_compute_health_check or google_compute_region_health_check to use. Conflicts with health_check_port."
  default     = null
  type        = string
}

variable backends {
  description = "Names of primary backend groups (IGs or IGMs). Typically use `module.vmseries.instance_group_self_links` here."
  type        = map(string)
}

variable failover_backends {
  description = "(Optional) Names of failover backend groups (IGs or IGMs). Failover groups are ignored unless the primary groups do not meet collective health threshold."
  default     = {}
  type        = map(string)
}

variable subnetwork {
  type = string
}

variable ip_address {
  default = null
}

variable ip_protocol {
  description = "(Optional) Ignored for route next hop. Incoming packets that are *not* using this load balancer as their next hop can only pass if they are using this protocol, either TCP or UDP, but not both. In the usual case of incoming packets that *are* routed to this load balancer as their next hop, this setting is ignored and [both TCP and UDP always pass](https://cloud.google.com/load-balancing/docs/internal/ilb-next-hop-overview#all-traffic)."
  default     = "TCP"
  type        = string
}

variable all_ports {
  description = "Forward all port numbers from the frontend to the backends. Needs to be null if `ports` are provided."
  default     = null
  type        = bool
}

variable ports {
  description = "Which port numbers are forwarded to the backends (up to 5 ports). Conflicts with `all_ports`. Ignored for route next hop traffic, just like the `ip_protocol` argument."
  default     = []
  type        = list(number)
}

variable network {
  default = null
}

variable session_affinity {
  description = "(Optional, TCP only) Try to direct sessions to the same backend, can be: CLIENT_IP, CLIENT_IP_PORT_PROTO, CLIENT_IP_PROTO, NONE (default is NONE)."
  default     = null
  type        = string
}


variable timeout_sec {
  description = "(Optional) How many seconds to wait for the backend before dropping the connection. Default is 30 seconds. Valid range is [1, 86400]."
  default     = null
  type        = number
}

variable disable_connection_drain_on_failover {
  description = "(Optional) On failover or failback, this field indicates whether connection drain will be honored. Setting this to true has the following effect: connections to the old active pool are not drained. Connections to the new active pool use the timeout of 10 min (currently fixed). Setting to false has the following effect: both old and new connections will have a drain timeout of 10 min. This can be set to true only if the protocol is TCP. The default is false."
  default     = null
  type        = bool
}

variable drop_traffic_if_unhealthy {
  description = "(Optional) Used only when no healthy VMs are detected in the primary and backup instance groups. When set to true, traffic is dropped. When set to false, new connections are sent across all VMs in the primary group. The default is false."
  default     = null
  type        = bool
}

variable failover_ratio {
  description = "(Optional) The value of the field must be in [0, 1]. If the ratio of the healthy VMs in the primary backend is at or below this number, traffic arriving at the load-balanced IP will be directed to the failover_backends. In case where 'failoverRatio' is not set or all the VMs in the backup backend are unhealthy, the traffic will be directed back to the primary backend in the `force` mode, where traffic will be spread to the healthy VMs with the best effort, or to all VMs when no VM is healthy. This field is only used with l4 load balancing."
  default     = null
  type        = number
}

variable allow_global_access {
  description = "(Optional) If true, clients can access ILB from all regions. By default false, only allow from the ILB's local region; useful if the ILB is a next hop of a route."
  default     = false
  type        = bool
}
