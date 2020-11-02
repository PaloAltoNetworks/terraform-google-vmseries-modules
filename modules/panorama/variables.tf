variable "subnetworks" { type = list(string) }
variable "names" { type = list(string) }

variable "panorama_image_file_name" {
  default = ""
  type    = string
}

variable "panorama_image_file_path" {
  default = "."
  type    = string
}

variable "panorama_bucket_name" {
  default = null
  type    = string
}

variable "region" {
  type = string
}

variable "zones" { type = list(string) }

variable "image_create_timeout" {
  default = "60m"
  type    = string
}

variable "storage_uri" {
  description = "(Optional) Custom URI prefix for Google Cloud Storage API."
  default     = "https://storage.cloud.google.com"
  type        = string
}

variable "nic0_ip" {
  type    = list(string)
  default = [""]
}

variable "nic0_public_ip" {
  type    = bool
  default = false
}


# variable instances {
#   description = "Definition of firewalls that will be deployed"
#   type        = map(any)
# }

variable machine_type {
  default = "n1-standard-16"
  type    = string
}

variable min_cpu_platform {
  default = "Intel Broadwell"
  type    = string
}

variable disk_type {
  description = "Default is pd-ssd, alternative is pd-balanced."
  default     = "pd-ssd"
}

variable ssh_key {
  default = ""
  type    = string
}

variable scopes {
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
  description = "The image name from which to boot an instance, including the license type and the version, e.g. vmseries-byol-814, vmseries-bundle1-814, vmseries-flex-bundle2-1001. Default is vmseries-flex-bundle1-913."
  default     = "vmseries-flex-bundle1-913"
  type        = string
}

variable image_uri {
  description = "The full URI to GCE image resource, the output of `gcloud compute images list --uri`. Overrides `image_name` and `image_prefix_uri` inputs."
  default     = null
  type        = string
}

variable labels {
  default = {}
  type    = map(any)
}

variable tags {
  default = []
  type    = list(string)
}

variable metadata {
  default = {}
  type    = map(string)
}

variable metadata_startup_script {
  description = "See the [Terraform manual](https://www.terraform.io/docs/providers/google/r/compute_instance.html)"
  default     = null
  type        = string
}

variable project {
  default = null
  type    = string
}

variable resource_policies {
  default = []
  type    = list(string)
}

variable service_account {
  description = "IAM Service Account for running firewall instance (just the email)"
  default     = null
  type        = string
}
