# Google Cloud HTTP/HTTPS External Global Load Balancer

Example:

```terraform

module "glb" {
  source = "../modules/gcp/lb_http_ext_global"
  name   = "my-glb"
  backends = {
    "0" = [
      {
        group                        = module.fw_inbound.instance_group[0]
        balancing_mode               = null
        capacity_scaler              = null
        description                  = null
        max_connections              = null
        max_connections_per_instance = null
        max_rate                     = null
        max_rate_per_instance        = null
        max_utilization              = null
      },
      {
        group                        = module.fw_inbound.instance_group[1]
        balancing_mode               = null
        capacity_scaler              = null
        description                  = null
        max_connections              = null
        max_connections_per_instance = null
        max_rate                     = null
        max_rate_per_instance        = null
        max_utilization              = null
      }
    ]
  }
  backend_params = [
    // health check path, port name, port number, timeout seconds.
    "/,http,80,10"
  ]
}

```
