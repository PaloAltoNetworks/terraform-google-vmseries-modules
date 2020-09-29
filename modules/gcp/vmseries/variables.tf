variable instances {
  description = "Definition of firewalls that will be deployed"
  type = map(object({
    name    = string
    zone    = string
    nic0_ip = string
    nic1_ip = string
    nic2_ip = string
  }))
}

variable subnetworks {
  description = "The ordered list of subnetworks. All the instances connect their interfaces to the same list of respective subnetworks."
  type        = list(string)
}

variable machine_type {
  default = "n1-standard-4"
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

variable bootstrap_bucket {
  default = ""
  type    = string
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

variable image {
}

variable tags {
  default = []
  type    = list(string)
}

variable create_instance_group {
  default = false
  type    = bool
}

variable dependencies {
  default = []
  type    = list(string)
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

variable service_account {
  description = "IAM Service Account for running firewall instance (just the email)"
  default     = null
  type        = string
}
