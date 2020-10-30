# Google Cloud HTTP/HTTPS External Global Load Balancer

A simplified GLB, which assumes that all participating instances are equally capable and that all
participating groups are equally capable as well.

## Example

```terraform

module "glb" {
  source = "../modules/lb_http_ext_global"
  name   = "my-glb"
  backend_groups        = module.vmseries.instance_group_self_links
  max_rate_per_instance = 50000
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
