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

The following requirements are needed by this module:

- google (~> 3.30)

## Required Inputs

The following input variables are required:

### name

Description: Name for the forwarding rule and prefix for supporting resources

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### backend\_groups

Description: The map containing the names of instance groups (IGs) or network endpoint groups (NEGs) to serve. The IGs can be managed or unmanaged or a mix of both. All IGs must handle named port `backend_port_name`. The NEGs just handle unnamed port.

Type: `map(string)`

Default: `{}`

### backend\_port\_name

Description: The port\_name of the backend groups that this load balancer will serve (default is 'http')

Type: `string`

Default: `"http"`

### backend\_protocol

Description: The protocol used to talk to the backend service

Type: `string`

Default: `"HTTP"`

### balancing\_mode

Description: n/a

Type: `string`

Default: `"RATE"`

### capacity\_scaler

Description: n/a

Type: `number`

Default: `null`

### cdn

Description: Set to `true` to enable cdn on backend.

Type: `bool`

Default: `false`

### certificate

Description: Content of the SSL certificate. Required if `ssl` is `true` and `ssl_certificates` is empty.

Type: `string`

Default: `""`

### http\_forward

Description: Set to `false` to disable HTTP port 80 forward

Type: `bool`

Default: `true`

### ip\_version

Description: IP version for the Global address (IPv4 or v6) - Empty defaults to IPV4

Type: `string`

Default: `""`

### max\_connections\_per\_instance

Description: n/a

Type: `number`

Default: `null`

### max\_rate\_per\_instance

Description: n/a

Type: `number`

Default: `null`

### max\_utilization

Description: n/a

Type: `number`

Default: `null`

### private\_key

Description: Content of the private SSL key. Required if `ssl` is `true` and `ssl_certificates` is empty.

Type: `string`

Default: `""`

### security\_policy

Description: The resource URL for the security policy to associate with the backend service

Type: `string`

Default: `""`

### ssl

Description: Set to `true` to enable SSL support, requires variable `ssl_certificates` - a list of self\_link certs

Type: `bool`

Default: `false`

### ssl\_certificates

Description: SSL cert self\_link list. Required if `ssl` is `true` and no `private_key` and `certificate` is provided.

Type: `list(string)`

Default: `[]`

### timeout\_sec

Description: Timeout to consider a connection dead, in seconds (default 30)

Type: `number`

Default: `null`

### url\_map

Description: The url\_map resource to use. Default is to send all traffic to first backend.

Type: `string`

Default: `null`

### use\_ssl\_certificates

Description: If true, use the certificates provided by `ssl_certificates`, otherwise, create cert from `private_key` and `certificate`

Type: `bool`

Default: `false`

## Outputs

The following outputs are exported:

### address

Description: n/a

### all

Description: Intended mainly for `depends_on` but currently succeeds prematurely (while forwarding rules and healtchecks are not yet usable).

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
