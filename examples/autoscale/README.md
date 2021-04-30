# Deployment of Palo Alto Networks VM-Series Firewalls with Autoscaling

The firewalls are created and destroyed by the GCP managed instance group.

For enhanced security, the firewalls' management interfaces are unreachable through public IP addresses (there is however a jumphost to aid initial troubleshooting).

## Caveat

1. The auto-scaling happens independently in each zone (it appears to be a limitation of GCP plugin 2.0.0 on Panorama, it simply does not check for the regional instance groups). The test was on Panorama 9.1.4.
2. The PanOS custom GCP metrics like `panSessionActive` require more work. See the GCP Metric Explorer.

## Instruction

- Set up Panorama and its VPC (consider using `examples/panorama`).
- Configure Panorama. This example assumes it exists with proper settings.
- Optionally, restart Panorama with `request restart system` to ensure the vm-auth-key is saved properly.
- Go to the main directory of the example (i.e. where this `README.md` is placed).
- Copy the `example.tfvars` into `terraform.tfvars` and modify it to your needs.
- Generate the SSH keys in the example's directory e.g.: `ssh-keygen -t rsa -C admin -N '' -f id_rsa`
- Manually edit the settings in `bootstrap_files/authcodes`
- Manually edit the settings in `bootstrap_files/init-cfg.txt`
- Deploy Terraform:

```sh
terraform init
terraform plan
terraform apply
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12, < 0.13 |
| <a name="requirement_google"></a> [google](#requirement\_google) | = 3.48 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | = 3.48 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_autoscale"></a> [autoscale](#module\_autoscale) | ../../modules/autoscale |  |
| <a name="module_bootstrap"></a> [bootstrap](#module\_bootstrap) | ../../modules/bootstrap/ |  |
| <a name="module_extlb"></a> [extlb](#module\_extlb) | ../../modules/lb_tcp_external/ |  |
| <a name="module_iam_service_account"></a> [iam\_service\_account](#module\_iam\_service\_account) | ../../modules/iam_service_account/ |  |
| <a name="module_intlb"></a> [intlb](#module\_intlb) | ../../modules/lb_tcp_internal/ |  |
| <a name="module_jumphost"></a> [jumphost](#module\_jumphost) | ../../modules/vmseries |  |
| <a name="module_jumpvpc"></a> [jumpvpc](#module\_jumpvpc) | ../../modules/vpc |  |
| <a name="module_mgmt_cloud_nat"></a> [mgmt\_cloud\_nat](#module\_mgmt\_cloud\_nat) | terraform-google-modules/cloud-nat/google | =1.2 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../../modules/vpc |  |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.this](https://registry.terraform.io/providers/hashicorp/google/3.48/docs/resources/compute_firewall) | resource |
| [null_resource.jumphost_ssh_priv_key](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [google_compute_zones.this](https://registry.terraform.io/providers/hashicorp/google/3.48/docs/data-sources/compute_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_autoscaler_metrics"></a> [autoscaler\_metrics](#input\_autoscaler\_metrics) | The map with the keys being metrics identifiers (e.g. custom.googleapis.com/VMSeries/panSessionUtilization).<br>Each of the contained objects has attribute `target` which is a numerical threshold for a scale-out or a scale-in.<br>Each zonal group grows until it satisfies all the targets.<br><br>Additional optional attribute `type` defines the metric as either `GAUGE` (the default), `DELTA_PER_SECOND`, or `DELTA_PER_MINUTE`.<br>For full specification, see the `metric` inside the [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_autoscaler). | `map` | <pre>{<br>  "custom.googleapis.com/VMSeries/panSessionActive": {<br>    "target": 100<br>  }<br>}</pre> | no |
| <a name="input_extlb_healthcheck_port"></a> [extlb\_healthcheck\_port](#input\_extlb\_healthcheck\_port) | n/a | `number` | `80` | no |
| <a name="input_extlb_name"></a> [extlb\_name](#input\_extlb\_name) | n/a | `string` | `"as4-fw-extlb"` | no |
| <a name="input_fw_image_uri"></a> [fw\_image\_uri](#input\_fw\_image\_uri) | Link to VM-Series PAN-OS image. Can be either a full self\_link, or one of the shortened forms per the [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#image). | `string` | `"https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/vmseries-byol-912"` | no |
| <a name="input_fw_machine_type"></a> [fw\_machine\_type](#input\_fw\_machine\_type) | n/a | `string` | `"n1-standard-4"` | no |
| <a name="input_fw_network_ordering"></a> [fw\_network\_ordering](#input\_fw\_network\_ordering) | A list of names from the `networks[*].name` attributes. | `list` | `[]` | no |
| <a name="input_intlb_global_access"></a> [intlb\_global\_access](#input\_intlb\_global\_access) | (Optional) If true, clients can access ILB from all regions. By default false, only allow from the ILB's local region; useful if the ILB is a next hop of a route. | `bool` | `false` | no |
| <a name="input_intlb_name"></a> [intlb\_name](#input\_intlb\_name) | n/a | `string` | `"as4-fw-intlb"` | no |
| <a name="input_intlb_network"></a> [intlb\_network](#input\_intlb\_network) | Name of the defined network that will host the Internal Load Balancer. One of the names from the `networks[*].name` attribute. | `any` | n/a | yes |
| <a name="input_mgmt_network"></a> [mgmt\_network](#input\_mgmt\_network) | Name of the network to create for firewall management. One of the names from the `networks[*].name` attribute. | `any` | n/a | yes |
| <a name="input_mgmt_sources"></a> [mgmt\_sources](#input\_mgmt\_sources) | n/a | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_networks"></a> [networks](#input\_networks) | The list of maps describing the VPC networks and subnetworks | `any` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to GCP resource names, an arbitrary string | `string` | `"as4"` | no |
| <a name="input_private_key_path"></a> [private\_key\_path](#input\_private\_key\_path) | Local path to private SSH key. To generate the key pair use `ssh-keygen -t rsa -C admin -N '' -f id_rsa` | `any` | `null` | no |
| <a name="input_public_key_path"></a> [public\_key\_path](#input\_public\_key\_path) | Local path to public SSH key. To generate the key pair use `ssh-keygen -t rsa -C admin -N '' -f id_rsa`  If you do not have a public key, run `ssh-keygen -f ~/.ssh/demo-key -t rsa -C admin` | `string` | `"id_rsa.pub"` | no |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | IAM Service Account for running firewall instances (just the identifier, without `@domain` part) | `string` | `"paloaltonetworks-fw"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_jumphost_ssh_command"></a> [jumphost\_ssh\_command](#output\_jumphost\_ssh\_command) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
