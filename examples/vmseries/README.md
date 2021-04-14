# Basic Example of vmseries Module Usage

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

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vmseries"></a> [vmseries](#module\_vmseries) | ../../modules/vmseries |  |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../../modules/vpc |  |

## Resources

| Name | Type |
|------|------|
| [google_compute_zones.this](https://registry.terraform.io/providers/hashicorp/google/3.48/docs/data-sources/compute_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_sources"></a> [allowed\_sources](#input\_allowed\_sources) | n/a | `list` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_image_uri"></a> [image\_uri](#input\_image\_uri) | n/a | `any` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ssh_command"></a> [ssh\_command](#output\_ssh\_command) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->