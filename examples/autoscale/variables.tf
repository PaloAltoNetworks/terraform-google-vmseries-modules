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

variable "ssh_keys" {
  type        = string
  default     = ""
  description = "VM-Series SSH keys. Format: 'admin:<ssh-rsa AAAA...>'"
}

variable "panorama_address" {
  description = "The Panorama IP address/FQDN.  The Panorama must be reachable from the management VPC. This build assumes Panorama is reachable via the internet. The management VPC network uses a NAT gateway to communicate to Panorama's external IP addresses."
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
  default     = null
}

variable "authcodes" {
  description = "VM-Series authcodes."
  type        = string
  default     = null
}

variable "panorama_auth_key" {
  description = "Panorama authorization key.  To generate, follow this guide https://docs.paloaltonetworks.com/vm-series/9-1/vm-series-deployment/license-the-vm-series-firewall/use-panorama-based-software-firewall-license-management"
  type        = string
  default     = null
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

#---------------------------------------------------------------------------------
# The following variables are used for delicensing Cloud Function

variable "delicensing_cloud_function_config" {
  description = <<-EOF
  Defining `delicensing_cloud_function_config` enables creation of delicesing cloud function and related resources.
  The variable contains the following configuration parameters that are related to Cloud Function:
  - `name_prefix`           - Resource name prefix
  - `function_name`         - Cloud Function base name
  - `region`                - Cloud Function region
  - `bucket_location`       - Cloud Function source code bucket location 
  - `panorama_address`      - Panorama IP address/FQDN
  - `vpc_connector_network` - Panorama VPC network Name
  - `vpc_connector_cidr`    - VPC connector /28 CIDR.
                              VPC connector will be user for delicensing CFN to access Panorama VPC network.
 
  Example:

  ```
  {
    name_prefix           = "abc-"
    function_name         = "delicensing-cfn"
    region                = "us-central1"
    bucket_location       = "US"
    panorama_address      = "1.1.1.1"
    vpc_connector_network = "panorama-vpc"
    vpc_connector_cidr    = "10.10.190.0/28"
  }
  ```
  EOF
  type = object({
    name_prefix           = optional(string)
    function_name         = optional(string)
    region                = string
    bucket_location       = string
    panorama_address      = string
    vpc_connector_network = string
    vpc_connector_cidr    = string
  })
  default = null
}

#---------------------------------------------------------------------------------
# The following variables are used for test VMs

variable "test_vms" {
  description = <<-EOF
  Test VMs

  Example:

  ```
  {
    "vm1" = {
      "zone" : "us-central1-a"
      "machine_type": "e2-micro"
    }
  }
  ```
  EOF
  type = map(object({
    zone         = string
    machine_type = string
  }))
  default = {}
}