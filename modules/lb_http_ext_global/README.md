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

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| google | ~> 3.30 |

## Providers

| Name | Version |
|------|---------|
| google | ~> 3.30 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| backend\_groups | The map containing the names of instance groups (IGs) or network endpoint groups (NEGs) to serve. The IGs can be managed or unmanaged or a mix of both. All IGs must handle named port `backend_port_name`. The NEGs just handle unnamed port. | `map(string)` | `{}` | no |
| backend\_port\_name | The port\_name of the backend groups that this load balancer will serve (default is 'http') | `string` | `"http"` | no |
| backend\_protocol | The protocol used to talk to the backend service | `string` | `"HTTP"` | no |
| balancing\_mode | n/a | `string` | `"RATE"` | no |
| capacity\_scaler | n/a | `number` | `null` | no |
| cdn | Set to `true` to enable cdn on backend. | `bool` | `false` | no |
| certificate | Content of the SSL certificate. Required if `ssl` is `true` and `ssl_certificates` is empty. | `string` | `""` | no |
| http\_forward | Set to `false` to disable HTTP port 80 forward | `bool` | `true` | no |
| ip\_version | IP version for the Global address (IPv4 or v6) - Empty defaults to IPV4 | `string` | `""` | no |
| max\_connections\_per\_instance | n/a | `number` | `null` | no |
| max\_rate\_per\_instance | n/a | `number` | `null` | no |
| max\_utilization | n/a | `number` | `null` | no |
| name | Name for the forwarding rule and prefix for supporting resources | `string` | n/a | yes |
| private\_key | Content of the private SSL key. Required if `ssl` is `true` and `ssl_certificates` is empty. | `string` | `""` | no |
| security\_policy | The resource URL for the security policy to associate with the backend service | `string` | `""` | no |
| ssl | Set to `true` to enable SSL support, requires variable `ssl_certificates` - a list of self\_link certs | `bool` | `false` | no |
| ssl\_certificates | SSL cert self\_link list. Required if `ssl` is `true` and no `private_key` and `certificate` is provided. | `list(string)` | `[]` | no |
| timeout\_sec | Timeout to consider a connection dead, in seconds (default 30) | `number` | `null` | no |
| url\_map | The url\_map resource to use. Default is to send all traffic to first backend. | `string` | `null` | no |
| use\_ssl\_certificates | If true, use the certificates provided by `ssl_certificates`, otherwise, create cert from `private_key` and `certificate` | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| address | n/a |
| all | Intended mainly for `depends_on` but currently succeeds prematurely (while forwarding rules and healtchecks are not yet usable). |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
