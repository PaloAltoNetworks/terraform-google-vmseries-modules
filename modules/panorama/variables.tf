variable panorama_image_file_name {
  description = "(Optional) Local filesystem file name (without the path component) of the file downloaded from https://support.paloaltonetworks.com from Software Updates - Panorama Base Images - GCP. The extension should be included (usually it is *.tar.gz). By default empty, which means to use either `image_name` or `image_uri` that point to a pre-existing image."
  default     = ""
  type        = string
}

variable panorama_image_file_path {
  description = "(Optional) Local filesystem path for the `panorama_image_file_name`. Used only when `panorama_image_file_name` is set. The *.tag.gz file is expected to be present at `panorama_image_file_path/panorama_image_file_name`."
  default     = "."
  type        = string
}

variable panorama_bucket_name {
  description = "(Optional) Bucket name used to hold the customized Panorama OS image. Used only when `panorama_image_file_name` is set."
  default     = "paloaltonetworks-panorama-os-image-bucket"
  type        = string
}

variable image_create_timeout {
  description = "(Optional) Timeout for uploading the *.tar.gz custom image file into the Google bucket. Default is `180m` (180 minutes)."
  default     = "180m"
  type        = string
}

variable storage_uri {
  description = "(Optional) Custom URI prefix for Google Cloud Storage API."
  default     = "https://storage.cloud.google.com"
  type        = string
}

variable instances {
  description = "Definition of Panorama cloud instances"
  type        = map(any)
}

variable public_nat {
  type    = bool
  default = false
}

variable machine_type {
  description = "See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)"
  default     = "n1-standard-16"
  type        = string
}

variable min_cpu_platform {
  description = "See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)"
  default     = "Intel Broadwell"
  type        = string
}

variable disk_type {
  description = "Type of boot disk. Default is pd-ssd, alternative is pd-balanced."
  default     = "pd-ssd"
  type        = string
}

variable disk_size {
  description = "Size of boot disk in gigabytes. Default is the same as the os image."
  default     = null
  type        = string
}

variable log_disk_type {
  description = "Type of disk holding traffic logs. Default is pd-standard, alternative is pd-ssd or pd-balanced."
  default     = "pd-standard"
  type        = string
}

variable log_disk_size {
  description = "Size of disk holding traffic logs in gigabytes. Default is 2000."
  default     = "2000"
  type        = string
}

variable ssh_key {
  default = ""
  type    = string
}

variable scopes {
  description = "See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)"
  default = [
    "https://www.googleapis.com/auth/compute.readonly",
    "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
  ]
  type = list(string)
}

variable image_prefix_uri {
  description = "The image URI prefix, by default https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/ string. When prepended to `image_name` it should result in a full valid Google Cloud Engine image resource URI."
  default     = "https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/"
  type        = string
}

variable image_name {
  description = "The image name from which to boot an instance, including the license type and the version, e.g. panorama-byol-901, panorama-byol-1000. Default is panorama-byol-912."
  default     = "panorama-byol-912"
  type        = string
}

variable image_uri {
  description = "The full URI to GCE image resource, the output of `gcloud compute images list --uri`. Overrides `image_name` and `image_prefix_uri` inputs."
  default     = null
  type        = string
}

variable labels {
  description = "See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)"
  default     = {}
  type        = map(any)
}

variable tags {
  description = "See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)"
  default     = []
  type        = list(string)
}

variable metadata {
  description = "See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)"
  default     = {}
  type        = map(string)
}

variable metadata_startup_script {
  description = "See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)"
  default     = null
  type        = string
}

variable project {
  description = "See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)"
  default     = null
  type        = string
}

variable resource_policies {
  description = "See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)"
  default     = []
  type        = list(string)
}

variable service_account {
  description = "IAM Service Account for running the instance (just the email)"
  default     = null
  type        = string
}
