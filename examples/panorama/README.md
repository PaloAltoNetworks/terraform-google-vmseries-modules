# Palo Alto Networks Panorama Module Example

>Panorama is a centralized management system that provides global visibility and control over multiple Palo Alto Networks next generation firewalls through an easy to use web-based interface. Panorama enables administrators to view aggregate or device-specific application, user, and content data and manage multiple Palo Alto Networks firewalls—all from a central location.

This folder shows an example of Terraform code that helps to deploy Panorama in the Google Cloud Platform.

## Usage

Create a `terraform.tfvars` file and copy the content of `example.tfvars` into it, adjust if needed.

```bash
$ terraform init
$ terraform apply
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.15.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_panorama"></a> [panorama](#module\_panorama) | ../../modules/panorama | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../../modules/vpc | n/a |

## Resources

| Name | Type |
|------|------|
| [google_compute_zones.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_sources"></a> [allowed\_sources](#input\_allowed\_sources) | n/a | `any` | n/a | yes |
| <a name="input_attach_public_ip"></a> [attach\_public\_ip](#input\_attach\_public\_ip) | n/a | `any` | n/a | yes |
| <a name="input_cidr"></a> [cidr](#input\_cidr) | n/a | `any` | n/a | yes |
| <a name="input_panorama_name"></a> [panorama\_name](#input\_panorama\_name) | Panorama | `any` | n/a | yes |
| <a name="input_panorama_version"></a> [panorama\_version](#input\_panorama\_version) | n/a | `any` | n/a | yes |
| <a name="input_private_static_ip"></a> [private\_static\_ip](#input\_private\_static\_ip) | n/a | `any` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | General | `any` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `any` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `any` | n/a | yes |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | n/a | `any` | n/a | yes |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | n/a | `any` | n/a | yes |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | VPC | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_panorama_private_ip"></a> [panorama\_private\_ip](#output\_panorama\_private\_ip) | Private IP address of the Panorama instance. |
| <a name="output_panorama_public_ip"></a> [panorama\_public\_ip](#output\_panorama\_public\_ip) | Public IP address of the Panorama instance. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->