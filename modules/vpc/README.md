# VPC Networks Module for GCP

The module that creates networks and subnetworks on GCP.

It is primarily intended for **Terraform 0.12.x** users, because it offers possibility to conditionally handle either new or pre-existing
networks/subnetworks without changing the source code. It is useful for 0.12 which doesn't allow conditional module instantiation.

This module is not strictly required for constructing inputs to be passed to other modules (including to vmseries or to autoscale modules).
Any existing networks/subnetworks can work equally well, independent on how they were created.

For Terraform 0.13+, a viable alternative is to use [Goggle-authored Terraform modules](https://registry.terraform.io/modules/terraform-google-modules/network)
and employ `for_each` or `count` parameters when needed.

## Reference
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2, < 2.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 4.54 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 4.54 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [google_compute_firewall.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_network.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_subnetwork.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_compute_network.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_network) | data source |
| [google_compute_subnetwork.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_network"></a> [create\_network](#input\_create\_network) | A flag to indicate the creation or import of a VPC network.<br>Setting this to `true` will create a new network managed by terraform.<br>Setting this to `false` will try to read the existing network with those name and region settings. | `bool` | `true` | no |
| <a name="input_delete_default_routes_on_create"></a> [delete\_default\_routes\_on\_create](#input\_delete\_default\_routes\_on\_create) | A flag to indicate the deletion of the default routes at VPC creation.<br>Setting this to `true` the default route `0.0.0.0/0` will be deleted upon network creation.<br>Setting this to `false` the default route `0.0.0.0/0` will be not be deleted upon network creation. | `bool` | `false` | no |
| <a name="input_firewall_rules"></a> [firewall\_rules](#input\_firewall\_rules) | A map containing firewall rules configuration.<br>Example :<pre>firewall_rules = {<br>  firewall-rule-1 = {<br>    name = "first-rule"<br>    source_ranges = ["10.10.10.0/24", "1.1.1.0/24"]<br>    priority = "2000"<br>    target_tags = ["vmseries-firewalls"]<br>    allowed_protocol = "TCP"<br>    allowed_ports = ["443", "22"]<br>  }<br>}</pre> | `any` | n/a | yes |
| <a name="input_mtu"></a> [mtu](#input\_mtu) | MTU value for VPC Network | `number` | `1460` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the created or already existing VPC Network. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project in which to create or look for VPCs and subnets | `string` | `null` | no |
| <a name="input_routing_mode"></a> [routing\_mode](#input\_routing\_mode) | Type of network-wide routing mode to use. Possible types are : REGIONAL and GLOBAL. | `string` | `"REGIONAL"` | no |
| <a name="input_subnetworks"></a> [subnetworks](#input\_subnetworks) | A map containing subnetworks configuration. Subnets can be in different regions<br>Example:<pre>subnetworks = {<br>  my-sub = {<br>    subnetwork_name = "my-sub"<br>    create_subnetwork = true<br>    ip_cidr_range = "192.168.0.0/24"<br>    region = "us-east1"<br>  }<br>}</pre> | `any` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_subnetworks"></a> [subnetworks](#output\_subnetworks) | n/a |
| <a name="output_subnetworks_by_key"></a> [subnetworks\_by\_key](#output\_subnetworks\_by\_key) | Map with subnetwork objects corresponding to input key (or index if list was provided) of `networks` variable. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
