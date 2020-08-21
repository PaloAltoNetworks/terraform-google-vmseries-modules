variable prefix {
  description = "Prefix to GCP resource names"
  type        = string
}

variable subnetworks {
  type = list(string)
}

variable machine_type {
  type = string
}

variable region {
  type = string
}

variable "zoning" {
  description = "Map of Zones to support single zone IGMs"
  default     = {}
  # FIXME type = list(string)
}

variable project_id {
  description = "Project ID/Name"
  type        = string
}

variable deployment_name {
  description = "Deployment Name that matches what is specified in Panorama GCP Plugin"
  type        = string
}

variable cpu_platform {
  type    = string
  default = "Intel Broadwell"
}

variable disk_type {
  type    = string
  default = "pd-ssd"
}

variable bootstrap_bucket {
  type    = string
  default = ""
}

variable ssh_key {
  type    = string
  default = ""
}

variable scopes {
  type = list(string)

  default = [
    "https://www.googleapis.com/auth/compute.readonly",
    "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
  ]
}

variable image {
  type = string
}

variable tags {
  type    = list(string)
  default = []
}

variable dependencies {
  type    = list(string)
  default = []
}

variable nic0_ip {
  type    = list(string)
  default = [""]
}

variable nic1_ip {
  type    = list(string)
  default = [""]
}

variable nic2_ip {
  type    = list(string)
  default = [""]
}

variable mgmt_interface_swap {
  default = ""
}

variable nic0_public_ip {
  type    = bool
  default = false
}

variable nic1_public_ip {
  type    = bool
  default = false
}

variable nic2_public_ip {
  type    = bool
  default = false
}

variable pool {
  description = "The self_link of google_compute_target_pool where the instances will be placed for healtchecking"
  type        = string
}

variable autoscaler_metric_name {
  type = string
}

variable autoscaler_metric_type {
  type = string
}

variable autoscaler_metric_target {
}
