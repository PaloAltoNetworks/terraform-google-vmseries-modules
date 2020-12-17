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
| terraform | >= 0.12, < 0.13 |
| google | = 3.48 |

## Providers

| Name | Version |
|------|---------|
| google | = 3.48 |
| null | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| autoscaler\_metrics | The map with the keys being metrics identifiers (e.g. custom.googleapis.com/VMSeries/panSessionUtilization).<br>Each of the contained objects has attribute `target` which is a numerical threshold for a scale-out or a scale-in.<br>Each zonal group grows until it satisfies all the targets.<br><br>Additional optional attribute `type` defines the metric as either `GAUGE` (the default), `DELTA_PER_SECOND`, or `DELTA_PER_MINUTE`.<br>For full specification, see the `metric` inside the [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_autoscaler). | `map` | <pre>{<br>  "custom.googleapis.com/VMSeries/panSessionActive": {<br>    "target": 100<br>  }<br>}</pre> | no |
| extlb\_healthcheck\_port | n/a | `number` | `80` | no |
| extlb\_name | n/a | `string` | `"as4-fw-extlb"` | no |
| fw\_image\_uri | Link to VM-Series PAN-OS image. Can be either a full self\_link, or one of the shortened forms per the [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#image). | `string` | `"https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/vmseries-byol-912"` | no |
| fw\_machine\_type | n/a | `string` | `"n1-standard-4"` | no |
| fw\_network\_ordering | A list of names from the `networks[*].name` attributes. | `list` | `[]` | no |
| intlb\_global\_access | (Optional) If true, clients can access ILB from all regions. By default false, only allow from the ILB's local region; useful if the ILB is a next hop of a route. | `bool` | `false` | no |
| intlb\_name | n/a | `string` | `"as4-fw-intlb"` | no |
| intlb\_network | Name of the defined network that will host the Internal Load Balancer. One of the names from the `networks[*].name` attribute. | `any` | n/a | yes |
| mgmt\_network | Name of the network to create for firewall management. One of the names from the `networks[*].name` attribute. | `any` | n/a | yes |
| mgmt\_sources | n/a | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| networks | The list of maps describing the VPC networks and subnetworks | `any` | n/a | yes |
| prefix | Prefix to GCP resource names, an arbitrary string | `string` | `"as4"` | no |
| private\_key\_path | Local path to private SSH key. To generate the key pair use `ssh-keygen -t rsa -C admin -N '' -f id_rsa` | `any` | `null` | no |
| public\_key\_path | Local path to public SSH key. To generate the key pair use `ssh-keygen -t rsa -C admin -N '' -f id_rsa`  If you do not have a public key, run `ssh-keygen -f ~/.ssh/demo-key -t rsa -C admin` | `string` | `"id_rsa.pub"` | no |
| service\_account | IAM Service Account for running firewall instances (just the identifier, without `@domain` part) | `string` | `"paloaltonetworks-fw"` | no |

## Outputs

| Name | Description |
|------|-------------|
| jumphost\_ssh\_command | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
