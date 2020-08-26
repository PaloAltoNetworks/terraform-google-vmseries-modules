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

## Instance Group (IG) re-use

IG that backs an ILB has to be in mode balancing_mode=CONNECTIONS:

```ini
Invalid value for field 'resource.backends[0].balancingMode': 'UTILIZATION'. Balancing mode must be CONNECTION for an INTERNAL backend service
```

Thus, it cannot be reused for this module (GLB), as it is incompatible with balancing_mode=CONNECTIONS:

```ini
CONNECTION balancing mode is not supported for protocol HTTP
```
