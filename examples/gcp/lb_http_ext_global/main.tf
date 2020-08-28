#########################################################################
# Global HTTP Load Balancer

module "glb" {
  source = "../../../modules/gcp/lb_http_ext_global"
  name   = "my-glb"
  backends = {
    "0" = [
      {
        group                        = module.vm.instance_group[0]
        balancing_mode               = "RATE"
        capacity_scaler              = null
        description                  = null
        max_connections              = null
        max_connections_per_instance = null
        max_rate                     = null
        max_rate_per_instance        = 50000
        max_utilization              = null
      },
      {
        group                        = module.vm.instance_group[1]
        balancing_mode               = "RATE"
        capacity_scaler              = null
        description                  = null
        max_connections              = null
        max_connections_per_instance = null
        max_rate                     = null
        max_rate_per_instance        = 50000
        max_utilization              = null
      }
    ]
  }
  backend_params = [
    // health check path, port name, port number, timeout seconds.
    "/,http,80,10"
  ]
}

output "global_url" {
  value = "http://${module.glb.address}"
}

#########################################################################
# Internal TCP Load Balancer
# 
# It's optional, just showing it can co-exist with a Global one.
# It is using secondary network interfaces, while the Global LB uses
# primary network interfaces.

module "ilb" {
  source            = "../../../modules/gcp/lb_tcp_internal"
  name              = "my-ilb"
  network           = "my-vpc"
  subnetworks       = ["my-subnet"]
  all_ports         = true
  ports             = []
  health_check_port = "22"

  backends = {
    "0" = [
      {
        group    = module.vm.instance_group[0],
        failover = false
      },
      {
        group    = module.vm.instance_group[1],
        failover = false
      }
    ]
  }
}

# output "internal_url" {
#   value = "http://${module.ilb.address}"   FIXME undefined
# }
