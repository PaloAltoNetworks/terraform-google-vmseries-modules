project      = "<project_id>"
region       = "us-central1"
network_name = "<network_name>"

vpn_gateway_name = "my-test-gateway"
router_name      = "my-test-router"

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
        redundancy_type = "SINGLE_IP_INTERNALLY_REDUNDANT"
        interfaces = [{
          id         = 0
          ip_address = "1.1.1.1"
        }]
      },
      tunnels = {
        remote00 = {
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
        remote01 = {
          bgp_peer = {
            address = "169.254.1.6"
            asn     = 65001
          }
          bgp_peer_options                = null
          bgp_session_range               = "169.254.1.5/30"
          ike_version                     = 2
          vpn_gateway_interface           = 1
          peer_external_gateway_interface = null
          shared_secret                   = "secret"
        }
      }
    }
    vpn-to-onprem2 = {
      name = "vpn-to-onprem2",
      peer_external_gateway = {
        redundancy_type = "TWO_IPS_REDUNDANCY"
        interfaces = [{
          id         = 0
          ip_address = "3.3.3.3"
          }, {
          id         = 1
          ip_address = "4.4.4.4"
        }]
      },
      tunnels = {
        remote10 = {
          bgp_peer = {
            address = "169.254.2.2"
            asn     = 65002
          }
          bgp_peer_options                = null
          bgp_session_range               = "169.254.2.1/30"
          ike_version                     = 2
          vpn_gateway_interface           = 0
          peer_external_gateway_interface = 0
          shared_secret                   = "secret"
        }
        remote11 = {
          bgp_peer = {
            address = "169.254.2.6"
            asn     = 65002
          }
          bgp_peer_options                = null
          bgp_session_range               = "169.254.2.5/30"
          ike_version                     = 2
          vpn_gateway_interface           = 1
          peer_external_gateway_interface = 1
          shared_secret                   = "secret"
        }
      }
    }
    vpn-to-gcp = {
      name = "vpn-to-gcp",

      peer_gcp_gateway = "https://www.googleapis.com/compute/v1/projects/<remote_project_id>/regions/<region>/vpnGateways/<remote_vpn_gw_name>"

      tunnels = {
        remote00 = {
          bgp_peer = {
            address = "169.254.3.2"
            asn     = 65003
          }
          bgp_peer_options                = null
          bgp_session_range               = "169.254.3.1/30"
          ike_version                     = 2
          vpn_gateway_interface           = 0
          peer_external_gateway_interface = null
          shared_secret                   = "secret"
        }
        remote01 = {
          bgp_peer = {
            address = "169.254.3.6"
            asn     = 65003
          }
          bgp_peer_options                = null
          bgp_session_range               = "169.254.3.5/30"
          ike_version                     = 2
          vpn_gateway_interface           = 1
          peer_external_gateway_interface = 1
          shared_secret                   = "secret"
        }
      }
    }
  }
}