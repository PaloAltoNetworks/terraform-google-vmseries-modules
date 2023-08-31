variable "name" {
  description = "VPN gateway name, and prefix used for dependent resources."
  type        = string
}

variable "network" {
  description = "VPC used for the gateway and routes."
  type        = string
}

variable "project" {
  description = "Project where resources will be created."
  type        = string
}

variable "region" {
  description = "Region used for resources."
  type        = string
}

variable "peer_external_gateway" {
  description = <<-EOF
  Configuration of an external VPN gateway to which this VPN is connected.

  type = object({
    name            = optional(string)
    redundancy_type = optional(string)
    interfaces = list(object({
      id         = number
      ip_address = string
    }))
  })
  EOF
  default     = null
}

variable "peer_gcp_gateway" {
  description = "Self Link URL of the peer side HA GCP VPN gateway to which this VPN tunnel is connected."
  type        = string
  default     = null
}

variable "route_priority" {
  description = "Route priority, defaults to 1000."
  type        = number
  default     = 1000
}

variable "router_advertise_config" {
  description = <<-EOF
  Router custom advertisement configuration, ip_ranges is a map of address ranges and descriptions

  type = object({
    groups    = list(string)
    ip_ranges = map(string)
    mode      = optional(string)
  })
  EOF
  default     = null
}

variable "router_asn" {
  description = "Router ASN used for auto-created router."
  type        = number
  default     = 64514
}

variable "keepalive_interval" {
  description = "The interval in seconds between BGP keepalive messages that are sent to the peer."
  type        = number
  default     = 20
}

variable "router_name" {
  description = "Existing Cloud Router name."
  type        = string
  default     = ""
}

variable "vpn_gateway_self_link" {
  description = "self_link of existing VPN gateway to be used for the vpn tunnel."
  type        = string
}

variable "tunnels" {
  description = <<-EOF
  VPN tunnel configurations, bgp_peer_options is usually null.

  type = map(object({
    bgp_peer = object({
      address = string
      asn     = number
    })
    bgp_session_name = optional(string)
    bgp_peer_options = optional(object({
      ip_address          = optional(string)
      advertise_groups    = optional(list(string))
      advertise_ip_ranges = optional(map(string))
      advertise_mode      = optional(string)
      route_priority      = optional(number)
    }))
    bgp_session_range               = optional(string)
    ike_version                     = optional(number)
    vpn_gateway_interface           = optional(number)
    peer_external_gateway_interface = optional(number)
    shared_secret                   = optional(string)
  }))
  EOF
  type        = map(any)
  default     = {}
}

variable "labels" {
  description = "Labels for vpn components"
  type        = map(string)
  default     = {}
}

variable "external_vpn_gateway_description" {
  description = "An optional description of external VPN Gateway"
  type        = string
  default     = "Terraform managed external VPN gateway"
}