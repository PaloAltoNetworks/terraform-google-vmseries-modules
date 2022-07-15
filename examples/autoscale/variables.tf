variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

#variable "auth_file" {
#  description = "GCP Project auth JSON file"
#  type        = string
#}

variable "region" {
  description = "GCP Region"
  default     = "us-east1"
  type        = string
}

variable "public_key_path" {
  description = "Local path to public SSH key. To generate the key pair use `ssh-keygen -t rsa -C admin -N '' -f id_rsa`  If you do not have a public key, run `ssh-keygen -f ~/.ssh/demo-key -t rsa -C admin`"
  default     = "~/.ssh/gcp-demo.pub"
}

variable "vmseries_image_name" {
  description = "Link to VM-Series PAN-OS image. Can be either a full self_link, or one of the shortened forms per the [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#image)."
  default     = "https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/vmseries-flex-byol-1014"
  type        = string
}

variable "vmseries_machine_type" {
  description = "The Google Compute instance type to run the VM-Series firewall.  N1 and N2 instance types are supported."
  default     = "n1-standard-4"
  type        = string
}


variable "vmseries_per_zone_max" {
  description = "The max number of firewalls to run in each zone."
  default     = 2
  type        = number
}

variable "vmseries_per_zone_min" {
  description = "The minimum number of firewalls to run in each zone."
  default     = 1
  type        = number
}

variable "prefix" {
  description = "Prefix to GCP resource names, an arbitrary string"
  default     = null
  type        = string
}

variable "autoscaler_metrics" {
  description = <<-EOF
  The map with the keys being metrics identifiers (e.g. custom.googleapis.com/VMSeries/panSessionUtilization).
  Each of the contained objects has attribute `target` which is a numerical threshold for a scale-out or a scale-in.
  Each zonal group grows until it satisfies all the targets.

  Additional optional attribute `type` defines the metric as either `GAUGE` (the default), `DELTA_PER_SECOND`, or `DELTA_PER_MINUTE`.
  For full specification, see the `metric` inside the [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_autoscaler).
  EOF
  default = {
    "custom.googleapis.com/VMSeries/panSessionActive" = {
      target = 100
    }
  }
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

variable "panorama_vm_auth_key" {
  description = "Panorama VM authorization key.  To generate, follow this guide https://docs.paloaltonetworks.com/vm-series/10-1/vm-series-deployment/bootstrap-the-vm-series-firewall/generate-the-vm-auth-key-on-panorama.html"
  type        = string
}

variable "panorama_address" {
  description = <<-EOF
  The Panorama IP/Domain address.  The Panorama address must be reachable from the management VPC.  
  This build assumes Panorama is reachable via the internet. The management VPC network uses a 
  NAT gateway to communicate to Panorama's external IP addresses.
  EOF
  type        = string
}

variable "panorama_device_group" {
  description = "The name of the Panorama device group that will bootstrap the VM-Series firewalls."
  type        = string
}

variable "panorama_template_stack" {
  description = "The name of the Panorama template stack that will bootstrap the VM-Series firewalls."
  type        = string
}
