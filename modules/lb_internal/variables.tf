variable "name" {
  description = "Name of the load balancer (that is, both the forwarding rule and the backend service)"
  type        = string
}

variable "health_check_port" {
  description = "(Optional) Port number for TCP healthchecking, default 22. This setting is ignored when `health_check` is provided."
  default     = 22
  type        = number
}

variable "health_check" {
  description = "(Optional) Name of either the global google_compute_health_check or google_compute_region_health_check to use. Conflicts with health_check_port."
  default     = null
  type        = string
}

variable "backends" {
  description = "Names of primary backend groups (IGs or IGMs). Typically use `module.vmseries.instance_group_self_links` here."
  type        = map(string)
}

variable "failover_backends" {
  description = "(Optional) Names of failover backend groups (IGs or IGMs). Failover groups are ignored unless the primary groups do not meet collective health threshold."
  default     = {}
  type        = map(string)
}

variable "subnetwork" {
  type = string
}

variable "ip_address" {
  default = null
}

variable "ip_protocol" {
  description = "The IP protocol for the frontend forwarding rule, valid values are TCP and UDP."
  default     = "TCP"
  type        = string
}

variable "all_ports" {
  description = "Forward all ports of the ip_protocol from the frontend to the backends. Needs to be null if `ports` are provided."
  default     = null
  type        = bool
}

variable "ports" {
  description = "Which port numbers are forwarded to the backends (up to 5 ports). Conflicts with all_ports."
  default     = []
  type        = list(number)
}

variable "network" {
  default = null
}

variable "session_affinity" {
  description = "(Optional, TCP only) Try to direct sessions to the same backend, can be: CLIENT_IP, CLIENT_IP_PORT_PROTO, CLIENT_IP_PROTO, NONE (default is NONE)."
  default     = null
  type        = string
}

variable "timeout_sec" {
  description = "(Optional) How many seconds to wait for the backend before dropping the connection. Default is 30 seconds. Valid range is [1, 86400]."
  default     = null
  type        = number
}

variable "check_interval_sec" {
  description = "(Optional) Define the amount of time from the start of one probe to the start of the next one."
  default     = null
  type        = number
}

variable "healthy_threshold" {
  description = "(Optional) Define the number of sequential probes that must succeed for the VM instance to be considered healthy."
  default     = null
  type        = number
}

variable "unhealthy_threshold" {
  description = "(Optional) Define the number of sequential probes that must fail for the VM instance to be considered unhealthy."
  default     = null
  type        = number
}

variable "disable_connection_drain_on_failover" {
  description = "(Optional) On failover or failback, this field indicates whether connection drain will be honored. Setting this to true has the following effect: connections to the old active pool are not drained. Connections to the new active pool use the timeout of 10 min (currently fixed). Setting to false has the following effect: both old and new connections will have a drain timeout of 10 min. This can be set to true only if the protocol is TCP. The default is false."
  default     = null
  type        = bool
}

variable "drop_traffic_if_unhealthy" {
  description = "(Optional) Used only when no healthy VMs are detected in the primary and backup instance groups. When set to true, traffic is dropped. When set to false, new connections are sent across all VMs in the primary group. The default is false."
  default     = null
  type        = bool
}

variable "failover_ratio" {
  description = "(Optional) The value of the field must be in [0, 1]. If the ratio of the healthy VMs in the primary backend is at or below this number, traffic arriving at the load-balanced IP will be directed to the failover_backends. In case where 'failoverRatio' is not set or all the VMs in the backup backend are unhealthy, the traffic will be directed back to the primary backend in the `force` mode, where traffic will be spread to the healthy VMs with the best effort, or to all VMs when no VM is healthy. This field is only used with l4 load balancing."
  default     = null
  type        = number
}

variable "allow_global_access" {
  description = "(Optional) If true, clients can access ILB from all regions. By default false, only allow from the ILB's local region; useful if the ILB is a next hop of a route."
  default     = false
  type        = bool
}

variable "connection_tracking_mode" {
  description = "(Optional) Specifies the key used for connection tracking. There are two options: PER_CONNECTION: The Connection Tracking is performed as per the Connection Key (default Hash Method) for the specific protocol. PER_SESSION: The Connection Tracking is performed as per the configured Session Affinity. It matches the configured Session Affinity. Default value is PER_CONNECTION. Possible values are PER_CONNECTION and PER_SESSION"
  default = "PER_CONNECTION"
  type = string
}

variable "connection_persistence_on_unhealthy_backends" {
  description = "(Optional) Specifies connection persistence when backends are unhealthy. If set to DEFAULT_FOR_PROTOCOL, the existing connections persist on unhealthy backends only for connection-oriented protocols (TCP and SCTP) and only if the Tracking Mode is PER_CONNECTION (default tracking mode) or the Session Affinity is configured for 5-tuple. They do not persist for UDP. If set to NEVER_PERSIST, after a backend becomes unhealthy, the existing connections on the unhealthy backend are never persisted on the unhealthy backend. They are always diverted to newly selected healthy backends (unless all backends are unhealthy). If set to ALWAYS_PERSIST, existing connections always persist on unhealthy backends regardless of protocol and session affinity. It is generally not recommended to use this mode overriding the default. Default value is DEFAULT_FOR_PROTOCOL. Possible values are DEFAULT_FOR_PROTOCOL, NEVER_PERSIST, and ALWAYS_PERSIST"
  default = "DEFAULT_FOR_PROTOCOL"
  type = string
}

variable "connection_idle_timeout_sec" {
  description = "(Optional) Specifies how long to keep a Connection Tracking entry while there is no matching traffic (in seconds). For L4 ILB the minimum(default) is 10 minutes and maximum is 16 hours. For NLB the minimum(default) is 60 seconds and the maximum is 16 hours."
  default = null
  type = number
}
