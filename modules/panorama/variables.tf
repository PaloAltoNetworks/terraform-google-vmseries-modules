variable "project" {
  description = "See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)"
  default     = null
  type        = string
}

variable "region" {}
variable "zone" {}

variable "panorama_name" {
  description = "The Panorama common name."
  default     = "panorama"
  type        = string
}

variable "subnet" {
}

variable "static_ip" {
  description = "The static private IP address for Panorama instance. Only IPv4 is supported. An address may only be specified for INTERNAL address types."
  default     = null
}

variable "attach_public_ip" {
  type    = bool
  default = false
}

variable "public_static_ip" {
  description = "The static external IP address for Panorama instance. Only IPv4 is supported. An address may only be specified for INTERNAL address types."
  default     = null
}

variable "log_disk_type" {
  description = "Type of disk holding traffic logs. Default is pd-standard, alternative is pd-ssd or pd-balanced."
  default     = "pd-standard"
  type        = string
}

variable "log_disk_size" {
  description = "Size of disk holding traffic logs in gigabytes. Default is 2000."
  default     = "2000"
  type        = string
}

variable "machine_type" {
  description = "See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)"
  default     = "n1-standard-16"
  type        = string
}

variable "min_cpu_platform" {
  description = "See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)"
  default     = "Intel Broadwell"
  type        = string
}

variable "labels" {
  description = "See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)"
  default     = {}
  type        = map(any)
}

variable "tags" {
  description = "See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)"
  default     = []
  type        = list(string)
}

variable "disk_type" {
  description = "Type of boot disk. Default is pd-ssd, alternative is pd-balanced."
  default     = "pd-ssd"
  type        = string
}

variable "disk_size" {
  description = "Size of boot disk in gigabytes. Default is the same as the os image."
  default     = null
  type        = string
}

variable "ssh_key" {
  default = ""
  type    = string
}

# variable "scopes" {
#   description = "See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)"
#   default = [
#     "https://www.googleapis.com/auth/compute.readonly",
#     "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
#     "https://www.googleapis.com/auth/devstorage.read_only",
#     "https://www.googleapis.com/auth/logging.write",
#     "https://www.googleapis.com/auth/monitoring.write",
#   ]
#   type = list(string)
# }

# variable "image_name" {
#   description = "The image name from which to boot an instance, including the license type and the version, e.g. panorama-byol-901, panorama-byol-1000. Default is panorama-byol-912."
#   default     = "panorama-byol-912"
#   type        = string
# }

# variable "image_uri" {
#   description = "The full URI to GCE image resource, the output of `gcloud compute images list --uri`. Overrides `image_name` and `image_prefix_uri` inputs."
#   default     = null
#   type        = string
# }

variable "image_project" {
  type    = string
  default = "paloaltonetworksgcp-public"
}

variable "image_family" {
  type    = string
  default = "panorama-10"
}

variable "metadata" {
  description = "See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)"
  default     = {}
  type        = map(string)
}

# variable "metadata_startup_script" {
#   description = "See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)"
#   default     = null
#   type        = string
# }

# variable "resource_policies" {
#   description = "See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)"
#   default     = []
#   type        = list(string)
# }

# variable "service_account" {
#   description = "IAM Service Account for running the instance (just the email)"
#   default     = null
#   type        = string
# }
