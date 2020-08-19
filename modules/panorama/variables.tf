variable "subnetworks"              { type = list(string) }
variable "names"                    { type = list(string) }
variable "machine_type"             { }
variable "panorama_image_file_name" { type = string }
variable "panorama_image_file_path" { type = string }
variable "panorama_bucket_name"     { type = string }
variable "region"                   { type = string }
variable "zones"                    { type = list(string) }
variable "cpu_platform"             { default = "Intel Broadwell" }
variable "disk_type"                { default = "pd-ssd" }
variable "bootstrap_bucket"         { default = "" }
variable "ssh_key"                  { default = "" }
variable "image"                    { }
variable "image_create_timeout"     { }
variable "storage_uri"              { }
variable "scopes" {
  type = list(string)

  default = [
    "https://www.googleapis.com/auth/compute.readonly",
    "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
  ]
}

variable "tags" {
  type    = list(string)
  default = []
}

variable "dependencies" {
  type    = list(string)
  default = []
}

variable "nic0_ip" {
  type    = list(string)
  default = [""]
}

variable "nic0_public_ip" {
  type    = bool
  default = false
}


