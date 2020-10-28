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
| google | = 3.35 |

## Providers

| Name | Version |
|------|---------|
| google | = 3.35 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| autoscaler\_metric\_name | n/a | `string` | `"custom.googleapis.com/VMSeries/panSessionActive"` | no |
| autoscaler\_metric\_target | n/a | `number` | `100` | no |
| autoscaler\_metric\_type | n/a | `string` | `"GAUGE"` | no |
| extlb\_healthcheck\_port | n/a | `number` | `80` | no |
| extlb\_name | n/a | `string` | `"as4-fw-extlb"` | no |
| fw\_image | n/a | `string` | `"https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/vmseries"` | no |
| fw\_machine\_type | n/a | `string` | `"n1-standard-4"` | no |
| fw\_panos | VM-Series license and PAN-OS version (ie: bundle1-814, bundle2-814, or byol-814) | `string` | `"byol-913"` | no |
| intlb\_name | n/a | `string` | `"as4-fw-intlb"` | no |
| mgmt\_sources | n/a | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| mgmt\_subnet | n/a | `list(string)` | n/a | yes |
| mgmt\_vpc | n/a | `any` | n/a | yes |
| prefix | Prefix to GCP resource names, an arbitrary string | `string` | `"as4"` | no |
| public\_key\_path | Local path to public SSH key. To generate the key pair use `ssh-keygen -t rsa -C admin -N '' -f id_rsa`  If you do not have a public key, run `ssh-keygen -f ~/.ssh/demo-key -t rsa -C admin` | `string` | `"id_rsa.pub"` | no |
| service\_account | IAM Service Account for running firewall instance (just the email) | `string` | `null` | no |
| trust\_subnet | Pre-existing subnets that contain the services and apps | `list(string)` | n/a | yes |
| trust\_vpc | Pre-existing VPC that contains the services and apps | `string` | n/a | yes |
| untrust\_subnet | n/a | `list(string)` | n/a | yes |
| untrust\_vpc | n/a | `any` | n/a | yes |

## Outputs

No output.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
