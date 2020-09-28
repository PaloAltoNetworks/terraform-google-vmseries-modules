variable firewalls {
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
  type = list(string)
}

variable machine_type {
}

variable min_cpu_platform {
  default = "Intel Broadwell"
  type    = string
}

variable disk_type {
  default = "pd-ssd"
  #default = "pd-standard"
}
variable bootstrap_bucket {
  default = ""
}

variable ssh_key {
  default = ""
}

variable public_lb_create {
  default = false
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
}

variable tags {
  type    = list(string)
  default = []
}

variable create_instance_group {
  type    = bool
  default = false
}

variable dependencies {
  type    = list(string)
  default = []
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

variable service_account {
  description = "IAM Service Account for running firewall instance (just the email)"
  default     = null
  type        = string
}
