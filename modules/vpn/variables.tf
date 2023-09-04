variable "project" {
  default = null
  type    = string
}

variable "region" {
  description = "Region to deploy VPN gateway in"
  type        = string
}

variable "vpn_gateway_name" {
  description = "VPN gateway name. Gateway created by the module"
  type        = string
}

variable "router_name" {
  description = "Cloud router name. The router is created by the module"
  type        = string
  default     = null
}

variable "network" {
  description = "VPC network ID that should be used for deployment"
  type        = string
}

variable "labels" {
  description = "Labels for VPN components"
  type        = map(string)
  default     = {}
}

variable "vpn_config" {
  type        = any
  description = <<-EOF
  VPN configuration from GCP to on-prem or from GCP to GCP.
  If you'd like secrets to be randomly generated set `shared_secret` to empty string ("").

  Example:

  ```
  vpn_config = {
    router_asn    = 65000
    local_network = "vpc-vpn"

    router_advertise_config = {
      ip_ranges = {
        "10.10.0.0/16" : "GCP range 1"
      }
      mode   = "CUSTOM"
      groups = null
    }

    instances = {
      vpn-to-onprem = {
        name = "vpn-to-onprem",
        peer_external_gateway = {
          redundancy_type = "TWO_IPS_REDUNDANCY"
          interfaces = [{
            id         = 0
            ip_address = "1.1.1.1"
            }, {
            id         = 1
            ip_address = "2.2.2.2"
          }]
        },
        tunnels = {
          remote0 = {
            bgp_peer = {
              address = "169.254.1.2"
              asn     = 65001
            }
            bgp_peer_options                = null
            bgp_session_range               = "169.254.1.1/30"
            ike_version                     = 2
            vpn_gateway_interface           = 0
            peer_external_gateway_interface = 0
            shared_secret                   = "secret"
          }
          remote1 = {
            bgp_peer = {
              address = "169.254.1.6"
              asn     = 65001
            }
            bgp_peer_options                = null
            bgp_session_range               = "169.254.1.5/30"
            ike_version                     = 2
            vpn_gateway_interface           = 1
            peer_external_gateway_interface = 1
            shared_secret                   = "secret"
          }
        }
      }
    }
  }
  ```
  EOF
}