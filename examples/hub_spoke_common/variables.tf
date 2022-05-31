variable "project_id" {
  description = "GCP project ID"
  default     = null
}
variable "prefix" {
  description = "Arbitrary string used to prefix resource names."
  type        = string
  default     = null
}
variable "region" {
  description = "Google Cloud region for the created resources."
  type        = string
  default     = null
}
variable "fw_machine_type" {
  description = "The Google Cloud machine type for the VM-Series NGFW."
  type        = string
  default     = "n1-standard-4"
}

variable "fw_image_name" {
  description = "The image name from which to boot an instance, including the license type and the version, e.g. vmseries-byol-814, vmseries-bundle1-814, vmseries-flex-bundle2-1001. Default is vmseries-flex-bundle1-913."
  type        = string
  default     = "vmseries-flex-byol-1014"
}

variable "allowed_sources" {
  description = "A list of IP addresses to be added to the management network's ingress firewall rule. The IP addresses will be able to access to the VM-Series management interface."
  type        = list(string)
  default     = null
}

variable "cidr_mgmt" {
  description = "The CIDR range of the management subnetwork."
  type        = string
  default     = null
}
variable "cidr_untrust" {
  description = "The CIDR range of the untrust subnetwork."
  type        = string
  default     = null
}
variable "cidr_trust" {
  description = "The CIDR range of the trust subnetwork."
  type        = string
  default     = null
}
variable "cidr_spoke1" {
  description = "The CIDR range of the management subnetwork."
  type        = string
  default     = null
}
variable "cidr_spoke2" {
  description = "The CIDR range of the spoke1 subnetwork."
  type        = string
  default     = null
}
variable "spoke_vm_type" {
  description = "The GCP machine type for the compute instances in the spoke networks."
  type        = string
  default     = "f1-micro"
}

variable "public_key_path" {
  description = "Local path to public SSH key.  If you do not have a public key, run >> ssh-keygen -f ~/.ssh/demo-key -t rsa -C admin"
  type        = string
  default     = null
}

variable "spoke_vm_image" {
  description = "The image path for the compute instances deployed in the spoke networks."
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2004-lts"
}

variable "spoke_vm_scopes" {
  description = "A list of service scopes. Both OAuth2 URLs and gcloud short names are supported. To allow full access to all Cloud APIs, use the cloud-platform"
  type        = list(string)
  default = [
    "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write"
  ]
}