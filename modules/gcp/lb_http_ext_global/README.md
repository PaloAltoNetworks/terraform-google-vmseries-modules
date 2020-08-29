# Google Cloud HTTP/HTTPS External Global Load Balancer

## Example

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

## Caveat emptor

Currently Google Cloud GLB can *only* send traffic to the primary network interface (`nic0`) of a backend instance.
One way to work around this is to use NEGs instead of IGs.

## Instance Group (IG) re-use

IG that backs an Internal TCP/UDP Load Balancer (ILB) enforces balancing_mode=CONNECTIONS:

```ini
Invalid value for field 'resource.backends[0].balancingMode': 'UTILIZATION'. Balancing mode must be CONNECTION for an INTERNAL backend service
```

Thus if you re-use the same IG for this module (HTTP LB) you need balancing_mode=RATE (and specify the max rate - don't worry it's not a circuit breaker). The balancing_mode=UTILIZATION is incompatible with ILB.
