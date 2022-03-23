# Palo Alto Networks Panorama Module for Google Clooud Platform

A Terraform module for deploying a Panorama instance in the Google Cloud Platform.

## Usage

For usage, check the "examples" folder in the root of the repository. 

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.29, < 2.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 3.30 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.15.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_address.private](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.public](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_disk.panorama_logs1](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_compute_disk.panorama_logs2](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_compute_instance.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_image.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attach_public_ip"></a> [attach\_public\_ip](#input\_attach\_public\_ip) | Determines if a Public IP should be assigned to Panorama. Set by the API if the `public_static_ip` variable is not defined. | `bool` | `false` | no |
| <a name="input_custom_image"></a> [custom\_image](#input\_custom\_image) | Custom image for your Panorama instances. Custom images are available only to your Cloud project. <br>You can create a custom image from boot disks and other images. <br>For more information, please check the provider [documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#image).<br><br>If a `custom_image` is not specified, `image_project` and `image_family` are used to determine a Public image to use for Panorama. | `string` | `null` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Size of boot disk in gigabytes. Default is the same as the os image. | `string` | `null` | no |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | Type of boot disk. Default is pd-ssd, alternative is pd-balanced. | `string` | `"pd-ssd"` | no |
| <a name="input_image_family"></a> [image\_family](#input\_image\_family) | For more information, please refer to the [Google Cloud documentation](https://cloud.google.com/compute/docs/images) | `string` | `"panorama-10"` | no |
| <a name="input_image_project"></a> [image\_project](#input\_image\_project) | For more information, please refer to the [Google Cloud documentation](https://cloud.google.com/compute/docs/images) | `string` | `"paloaltonetworksgcp-public"` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | `map(any)` | `{}` | no |
| <a name="input_log_disk_size"></a> [log\_disk\_size](#input\_log\_disk\_size) | Size of disk holding traffic logs in gigabytes. Default is 2000. | `string` | `"2000"` | no |
| <a name="input_log_disk_type"></a> [log\_disk\_type](#input\_log\_disk\_type) | Type of disk holding traffic logs. Default is pd-standard, alternative is pd-ssd or pd-balanced. | `string` | `"pd-standard"` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | `string` | `"n1-standard-16"` | no |
| <a name="input_metadata"></a> [metadata](#input\_metadata) | See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | `map(string)` | `{}` | no |
| <a name="input_min_cpu_platform"></a> [min\_cpu\_platform](#input\_min\_cpu\_platform) | See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | `string` | `"Intel Broadwell"` | no |
| <a name="input_panorama_name"></a> [panorama\_name](#input\_panorama\_name) | Name of the Panorama instance. | `string` | `"panorama"` | no |
| <a name="input_private_static_ip"></a> [private\_static\_ip](#input\_private\_static\_ip) | The static private IP address for Panorama. Only IPv4 is supported. An address may only be specified for INTERNAL address types.<br>  The IP address must be inside the specified subnetwork, if any. Set by the API if undefined. | `string` | `null` | no |
| <a name="input_project"></a> [project](#input\_project) | The ID of the project in which the resource belongs. If it is not provided, the provider project is used. | `string` | `"null"` | no |
| <a name="input_public_static_ip"></a> [public\_static\_ip](#input\_public\_static\_ip) | The static external IP address for Panorama instance. Only IPv4 is supported. Set by the API if undefined. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Google Cloud region to deploy the resources into. | `string` | n/a | yes |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | In order to connect via SSH to Panorama, provide your SSH public key here.<br>  Remember to add the `admin` prefix before you insert your public SSH key.<br><br>  Example:<br><br>  `ssh_key = "admin:ssh-rsa AAAAB4NzaC5yc9EAACABBACBgQDAcjYw6xa2zUZ6reqHqDp9bYDLTu7Rnk5Sa3hthIsIsFaKenFLe4w3mm5eF3ebsfAAnuzI9ua9g7aB/ThIsIsAlSoFaKeN2VhUMDmlBYO5m1D4ip6eugS6uM="` | `string` | n/a | yes |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | A regional resource, defining a range of IPv4 addresses. In Google Cloud, the terms subnet and subnetwork are synonymous. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | `list(string)` | `[]` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | Deployment area for Google Cloud resources within a region. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nic0_private_ip"></a> [nic0\_private\_ip](#output\_nic0\_private\_ip) | Panorama private IP. |
| <a name="output_nic0_public_ip"></a> [nic0\_public\_ip](#output\_nic0\_public\_ip) | Panorama public IP. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
