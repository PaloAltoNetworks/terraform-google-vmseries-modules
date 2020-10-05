variable instances {
  type = map(object({
    name       = string,
    zone       = string,
    subnetwork = string
  }))
}

variable machine_type {
}

variable create_instance_group {
  type    = bool
  default = false
}

variable ssh_key {
  default = ""
}

variable image {
}

variable scopes {
  type = list(string)

  default = [
    "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
  ]
}

variable startup_script {
  default = ""
}

