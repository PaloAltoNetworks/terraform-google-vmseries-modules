variable "project_id" {
  description = "GCP Project ID to contain the created cloud resources."
  type        = string
}

variable "name_prefix" {
  description = "Prefix to prepend the resource names. This is useful for identifing the created resources."
  type        = string
  default     = ""
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "allowed_sources" {
  description = "A list of IP addresses to be added to the management network's ingress firewall rule. The IP addresses will be able to access to the VM-Series management interface."
  type        = list(string)
}

variable "vmseries_image_name" {
  description = " Link to VM-Series PAN-OS image. Can be either a full self_link, or one of the shortened forms per the [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#image)."
  type        = string
  #default     = "https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/vmseries-flex-bundle2-1014"
}

variable "vmseries_instances_min" {
  description = "The minimum number of VM-Series that the autoscaler can scale down to. This cannot be less than 0."
  type        = number
  default     = 2
}

variable "vmseries_instances_max" {
  description = "The maximum number of VM-Series that the autoscaler can scale up to. This is required when creating or updating an autoscaler. The maximum number of VM-Series should not be lower than minimal number of VM-Series."
  type        = number
  default     = 5
}

variable "panorama_address" {
  description = "The Panorama IP/Domain address.  The Panorama address must be reachable from the management VPC. This build assumes Panorama is reachable via the internet. The management VPC network uses a NAT gateway to communicate to Panorama's external IP addresses."
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

variable "panorama_vm_auth_key" {
  description = "Panorama VM authorization key.  To generate, follow this guide https://docs.paloaltonetworks.com/vm-series/10-1/vm-series-deployment/bootstrap-the-vm-series-firewall/generate-the-vm-auth-key-on-panorama.html"
  type        = string
}


variable "vmseries_machine_type" {
  description = "(Optional) The instance type for the VM-Series firewalls."
  type        = string
  default     = "n2-standard-4"
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

variable "cidr_mgmt" {
  description = "The CIDR range of the management subnetwork."
  type        = string
  default     = "10.0.0.0/28"
}

variable "cidr_untrust" {
  description = "The CIDR range of the untrust subnetwork."
  type        = string
  default     = "10.0.1.0/28"
}

variable "cidr_trust" {
  description = "The CIDR range of the trust subnetwork."
  type        = string
  default     = "10.0.2.0/28"
}