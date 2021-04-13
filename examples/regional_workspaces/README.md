# Regional Terraform Workspaces Example

## Description

A multi-region and multi-environment deployment, where the region is geographical and environment means dev, qa, prod, etc.

Every region, and every environment in it, uses:

- a separate Terraform Workspace (In other words it has a separate Terraform state.)
- a separate variable file,
- but, crucially, the same Terraform code.

## Instruction

### Brownfield

Here, brownfield are the VPC networks and subnetworks that are already existant
before our main deployment of this example runs. These resources
come from outside, e.g. from some native deployment manager or manual ui work.

We have a minimal Terraform code that creates the brownfield VPCs, and the main code of this example "pretends"
that these were already existent.

- Set up the simulation of the brownfield:

```sh
cd brownfield
terraform init
terraform apply
cd -
```

### Main Deployment

- Set up Panorama. This example assumes it exists with proper settings.
- Set the GCP Service Account with the sufficient permissions. The account will not only be used for GCP plugin access, but also for actually running the instances.
- Go to the main directory of the example (i.e. where this README.md is placed)
- Create Terraform Workspaces with naming convention: `<myprefix>-<environment>-firewalls+<region>`
- Put the created items into your `<environment>.tfvars`: (For multiple environment types please ensure the coincide with the environment name created in the workspace )
- Update `general.auto.tfvars` with variables that are intended to be identical in all environments
- Run commands:

```sh
terraform init
terraform workspace new '<myprefix>-<environment>-firewalls+<region>'
terraform workspace select '<myprefix>-<environment>-firewalls+<region>'
terraform init
terraform plan -var-file=<environment>.tfvars
terraform apply -var-file=<environment>.tfvars
```

## Common errors

### Invalid index

```txt
Error: Invalid index

  on main.tf line ...
    |----------------
    | local.region is "default"
    | var.regions is object with 1 attribute "us-central1"
```

The reason is wrong workspace, indicated by `*` below:

```sh
$ terraform workspace list
* default
  example-another
  example-nonprod-firewalls+us-central1
```

Apply the main instruction again to correct the situation:

```sh
$ terraform workspace new 'example-nonprod-firewalls+us-central1'
Workspace "example-nonprod-firewalls+us-central1" already exists
$ terraform workspace select 'example-nonprod-firewalls+us-central1'
$ terraform workspace list
  default
  example-another
* example-nonprod-firewalls+us-central1
```

Make sure that the workspace name marked `*` is suffixed with `+us-central1` or similar. It needs
to be a plus sign `+` followed by a valid Google Cloud Region name, and the region needs to be
referenced in your variable `regions`. In this example, the code would expect `regions["us-central1"]`
to be defined by you.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>0.12 |
| <a name="requirement_google"></a> [google](#requirement\_google) | = 3.48 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bootstrap"></a> [bootstrap](#module\_bootstrap) | ../../modules/bootstrap/ |  |
| <a name="module_firewalls"></a> [firewalls](#module\_firewalls) | ../../modules/vmseries |  |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../../modules/vpc |  |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auth_file"></a> [auth\_file](#input\_auth\_file) | GCP Project auth JSON file | `string` | n/a | yes |
| <a name="input_develop_locally"></a> [develop\_locally](#input\_develop\_locally) | Go local development | `bool` | `false` | no |
| <a name="input_fw_machine_type"></a> [fw\_machine\_type](#input\_fw\_machine\_type) | VM size, e.g. n1-standard-16 | `any` | `null` | no |
| <a name="input_http_basic_auth"></a> [http\_basic\_auth](#input\_http\_basic\_auth) | The result of `echo -n 'mynewuser:newpassword' | base64` which is known by the clients of the route-operator API server. | `string` | `"bXluZXd1c2VyOm5ld3Bhc3N3b3Jk"` | no |
| <a name="input_https_cert_pem_file"></a> [https\_cert\_pem\_file](#input\_https\_cert\_pem\_file) | Certificate (possibly self-signed) for the route-operator https API. The file can also contain a concatenated chain of certificates. | `string` | `"cert.pem"` | no |
| <a name="input_https_interm_pem_file"></a> [https\_interm\_pem\_file](#input\_https\_interm\_pem\_file) | The parent certificate that signed `https_cert_pem_file` certificate. The X509 field Subject should equal to the X509 field Issuer of `https_cert_pem_file`. | `string` | `"interm.pem"` | no |
| <a name="input_https_key_pem_file"></a> [https\_key\_pem\_file](#input\_https\_key\_pem\_file) | The private key file that corresponds to the first `https_cert_pem_file` certificate. | `string` | `"key.pem"` | no |
| <a name="input_outbound_route_dest"></a> [outbound\_route\_dest](#input\_outbound\_route\_dest) | When creating outbound routes (i.e. routes from GCP to the Internet) what destination to use. For production environment set to 0.0.0.0/0 but it can be quite a pain during tests. | `string` | n/a | yes |
| <a name="input_panos_image_name"></a> [panos\_image\_name](#input\_panos\_image\_name) | VM-Series license and PAN-OS (ie: vmseries-bundle1-912, vmseries-byol-814, etc) | `string` | `"vmseries-flex-byol-913"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to GCP resource names | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project ID | `string` | n/a | yes |
| <a name="input_public_key_path"></a> [public\_key\_path](#input\_public\_key\_path) | Local path to public SSH key. If you do not have a public key, run >> ssh-keygen -f ~/.ssh/demo-key -t rsa -C admin | `string` | `"~/.ssh/id_rsa.pub"` | no |
| <a name="input_regions"></a> [regions](#input\_regions) | n/a | `any` | n/a | yes |
| <a name="input_ro_ilb_name"></a> [ro\_ilb\_name](#input\_ro\_ilb\_name) | n/a | `string` | `""` | no |
| <a name="input_ro_ip_address"></a> [ro\_ip\_address](#input\_ro\_ip\_address) | The IP of the route-operator API. Points to an Internal Load Balancer. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_info"></a> [info](#output\_info) | Basic Known information output regarding region/environment/projectID |
| <a name="output_management_addresses"></a> [management\_addresses](#output\_management\_addresses) | VM-Series Firewall Management Addresses |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
