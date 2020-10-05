variable instances {
  type = map(object({
    name       = string,
    zone       = string,
    subnetwork = string
  }))
}

variable machine_type {
}

variable ssh_public_key {
}

variable ssh_private_key {
}

variable ssh_user {
  default = "ubuntu"
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
    "https://www.googleapis.com/auth/compute",
  ]
}

variable "healthy_threshold" {
  description = "A so-far unhealthy instance will be marked healthy after this many consecutive successes."
  default     = 3
  type        = number
}

variable "unhealthy_threshold" {
  description = "A so-far healthy instance will be marked unhealthy after this many consecutive failures."
  default     = 2
  type        = number
}

variable routes {
  default = {}
}

variable https_key_pem_file {
  description = "The private key file that corresponds to the first `https_cert_pem_file` certificate."
  default     = "key.pem"
}

variable https_cert_pem_file {
  description = "Certificate (possibly self-signed) for the route-operator https API. The file can also contain a concatenated chain of certificates."
  default     = "cert.pem"
}

variable https_interm_pem_file {
  description = "The parent certificate that signed `https_cert_pem_file` certificate. The X509 field Subject should equal to the X509 field Issuer of `https_cert_pem_file`."
  default     = "interm.pem"
}

variable http_basic_auth {
  description = "The result of `echo -n 'mynewuser:newpassword' | base64` which is known by the clients of the route-operator API server."
  default     = "bXluZXd1c2VyOm5ld3Bhc3N3b3Jk"
  type        = string
}

variable develop_locally {
  description = "Go local development"
  default     = false
  type        = bool
}
