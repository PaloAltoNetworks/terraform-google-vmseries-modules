# Panorama Module

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.29, < 2.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 3.30 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 3.30 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_address.private](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.public](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_disk.panorama_logs1](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_compute_disk.panorama_logs2](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_compute_image.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_image) | resource |
| [google_compute_instance.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_storage_bucket.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_object.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |
| [google_compute_subnetwork.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Size of boot disk in gigabytes. Default is the same as the os image. | `string` | `null` | no |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | Type of boot disk. Default is pd-ssd, alternative is pd-balanced. | `string` | `"pd-ssd"` | no |
| <a name="input_image_create_timeout"></a> [image\_create\_timeout](#input\_image\_create\_timeout) | (Optional) Timeout for uploading the *.tar.gz custom image file into the Google bucket. Default is `180m` (180 minutes). | `string` | `"180m"` | no |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | The image name from which to boot an instance, including the license type and the version, e.g. panorama-byol-901, panorama-byol-1000. Default is panorama-byol-912. | `string` | `"panorama-byol-912"` | no |
| <a name="input_image_prefix_uri"></a> [image\_prefix\_uri](#input\_image\_prefix\_uri) | The image URI prefix, by default https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/ string. When prepended to `image_name` it should result in a full valid Google Cloud Engine image resource URI. | `string` | `"https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/"` | no |
| <a name="input_image_uri"></a> [image\_uri](#input\_image\_uri) | The full URI to GCE image resource, the output of `gcloud compute images list --uri`. Overrides `image_name` and `image_prefix_uri` inputs. | `string` | `null` | no |
| <a name="input_instances"></a> [instances](#input\_instances) | Definition of Panorama cloud instances | `map(any)` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | `map(any)` | `{}` | no |
| <a name="input_log_disk_size"></a> [log\_disk\_size](#input\_log\_disk\_size) | Size of disk holding traffic logs in gigabytes. Default is 2000. | `string` | `"2000"` | no |
| <a name="input_log_disk_type"></a> [log\_disk\_type](#input\_log\_disk\_type) | Type of disk holding traffic logs. Default is pd-standard, alternative is pd-ssd or pd-balanced. | `string` | `"pd-standard"` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | `string` | `"n1-standard-16"` | no |
| <a name="input_metadata"></a> [metadata](#input\_metadata) | See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | `map(string)` | `{}` | no |
| <a name="input_metadata_startup_script"></a> [metadata\_startup\_script](#input\_metadata\_startup\_script) | See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | `string` | `null` | no |
| <a name="input_min_cpu_platform"></a> [min\_cpu\_platform](#input\_min\_cpu\_platform) | See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | `string` | `"Intel Broadwell"` | no |
| <a name="input_panorama_bucket_name"></a> [panorama\_bucket\_name](#input\_panorama\_bucket\_name) | (Optional) Bucket name used to hold the customized Panorama OS image. Used only when `panorama_image_file_name` is set. | `string` | `"paloaltonetworks-panorama-os-image-bucket"` | no |
| <a name="input_panorama_image_file_name"></a> [panorama\_image\_file\_name](#input\_panorama\_image\_file\_name) | (Optional) Local filesystem file name (without the path component) of the file downloaded from https://support.paloaltonetworks.com from Software Updates - Panorama Base Images - GCP. The extension should be included (usually it is *.tar.gz). By default empty, which means to use either `image_name` or `image_uri` that point to a pre-existing image. | `string` | `""` | no |
| <a name="input_panorama_image_file_path"></a> [panorama\_image\_file\_path](#input\_panorama\_image\_file\_path) | (Optional) Local filesystem path for the `panorama_image_file_name`. Used only when `panorama_image_file_name` is set. The *.tag.gz file is expected to be present at `panorama_image_file_path/panorama_image_file_name`. | `string` | `"."` | no |
| <a name="input_project"></a> [project](#input\_project) | See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | `string` | `null` | no |
| <a name="input_public_nat"></a> [public\_nat](#input\_public\_nat) | n/a | `bool` | `false` | no |
| <a name="input_resource_policies"></a> [resource\_policies](#input\_resource\_policies) | See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | `list(string)` | `[]` | no |
| <a name="input_scopes"></a> [scopes](#input\_scopes) | See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | `list(string)` | <pre>[<br>  "https://www.googleapis.com/auth/compute.readonly",<br>  "https://www.googleapis.com/auth/cloud.useraccounts.readonly",<br>  "https://www.googleapis.com/auth/devstorage.read_only",<br>  "https://www.googleapis.com/auth/logging.write",<br>  "https://www.googleapis.com/auth/monitoring.write"<br>]</pre> | no |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | IAM Service Account for running the instance (just the email) | `string` | `null` | no |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | n/a | `string` | `""` | no |
| <a name="input_storage_uri"></a> [storage\_uri](#input\_storage\_uri) | (Optional) Custom URI prefix for Google Cloud Storage API. | `string` | `"https://storage.cloud.google.com"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nic0_private_ips"></a> [nic0\_private\_ips](#output\_nic0\_private\_ips) | n/a |
| <a name="output_nic0_public_ips"></a> [nic0\_public\_ips](#output\_nic0\_public\_ips) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
