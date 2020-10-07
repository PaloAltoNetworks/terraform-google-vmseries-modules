variable "regions" {
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "auth_file" {
  description = "GCP Project auth JSON file"
  type        = string
}

variable "prefix" {
  description = "Prefix to GCP resource names"
  type        = string
}

variable public_key_path {
  description = "Local path to public SSH key. If you do not have a public key, run >> ssh-keygen -f ~/.ssh/demo-key -t rsa -C admin"
  default     = "~/.ssh/id_rsa.pub"
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

# ----------
# Licencing and VM settings
variable panos_image_name {
  description = "VM-Series license and PAN-OS (ie: vmseries-bundle1-912, vmseries-byol-814, etc)"
  default     = "vmseries-flex-byol-913"
}

variable fw_machine_type {
  description = "VM size, e.g. n1-standard-16"
  default     = null
}

variable https_cert_pem_file {
  description = "Certificate (possibly self-signed) for the route-operator https API. The file can also contain a concatenated chain of certificates."
  default     = "cert.pem"
}

variable https_key_pem_file {
  description = "The private key file that corresponds to the first `https_cert_pem_file` certificate."
  default     = "key.pem"
}

variable outbound_route_dest {
  description = "When creating outbound routes (i.e. routes from GCP to the Internet) what destination to use. For production environment set to 0.0.0.0/0 but it can be quite a pain during tests."
  type        = string
}

variable develop_locally {
  description = "Go local development"
  default     = false
  type        = bool
}

variable ro_ip_address {
  description = "The IP of the route-operator API. Points to an Internal Load Balancer."
  default     = null
  type        = string
}

variable ro_ilb_name {
  default = ""
}
