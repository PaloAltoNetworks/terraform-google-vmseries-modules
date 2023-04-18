variable "name" {
  description = "(Required) The name of the VM-Series deployed.  This value will be used as the `base_instance_name` and will be used as a prepended prefix for other created resources."
  type        = string
}

variable "network_interfaces" {
  description = <<-EOF
  (Required) List of the network interface specifications.
  
  Available options:
  - `subnetwork`             - (Required|string) Self-link of a subnetwork to create interface in.
  - `create_public_ip`       - (Optional|boolean) Whether to reserve public IP for the interface.
  EOF
  type        = list(any)
}

variable "use_regional_mig" {
  description = "(Required) Sets the managed instance group type to either a zone-based instance group or to a regional instance group.  If value is set to `true`, a regional instance group will be created.  If false, a zone-based instance group will be created.  For more information please see [About regional MIGs](https://cloud.google.com/compute/docs/instance-groups/regional-migs#why_choose_regional_managed_instance_groups)."
  type        = bool
}

variable "max_vmseries_replicas" {
  description = "(Required) The maximum number of VM-Series that the autoscaler can scale up to. This is required when creating or updating an autoscaler. The maximum number of VM-Series should not be lower than minimal number of VM-Series."
  type        = number
}

variable "min_vmseries_replicas" {
  description = "(Required) The minimum number of VM-Series that the autoscaler can scale down to. This cannot be less than 0."
  type        = number
}

variable "region" {
  description = "(Required) The Google Cloud region for the resources.  If null is provided, provider region will be used."
  type        = string
  default     = null
}

variable "zones" {
  description = "Required if `use_regional_mig` is set to `false`.  A map of the zone names for zone-based managed instance groups.  A managed instance group will be created for every zone entered."
  type        = map(string)
  default     = {}
}

variable "create_pubsub_topic" {
  description = "(Optional)  Set to `true` to create a Pub/Sub topic and subscription.  The Panorama Google Cloud Plugin can use this Pub/Sub to trigger actions when the VM-Series Instance Group descales.  Actions include, removal of VM-Series from Panorama and automatic delicensing (if VM-Series BYOL licensing is used).  For more information, please see [Autoscaling the VM-Series on GCP](https://docs.paloaltonetworks.com/vm-series/9-1/vm-series-deployment/set-up-the-vm-series-firewall-on-google-cloud-platform/autoscaling-on-google-cloud-platform)."
  type        = bool
  default     = true
}

variable "machine_type" {
  description = "(Optional) The instance type for the VM-Series firewalls."
  type        = string
  default     = "n2-standard-4"
}

variable "min_cpu_platform" {
  description = "(Optional) The minimum CPU platform for the instance type of the VM-Series firewalls."
  type        = string
  default     = "Intel Cascade Lake"
}

variable "disk_type" {
  description = "(Optional) The disk type that is attached to the instances of the VM-Series firewalls."
  type        = string
  default     = "pd-ssd"
}

variable "scopes" {
  description = "(Optional) A list of service scopes. Both OAuth2 URLs and gcloud short names are supported.  See a complete list of scopes [here](https://cloud.google.com/sdk/gcloud/reference/alpha/compute/instances/set-scopes#--scopes)."
  type        = list(string)
  default = [
    "https://www.googleapis.com/auth/compute.readonly",
    "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
  ]
}



variable "image" {
  description = "(Optional) Link to VM-Series PAN-OS image. Can be either a full self_link, or one of the shortened forms per the [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#image)."
  type        = string
  default     = "https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/vmseries-byol-1014"
}


variable "tags" {
  description = "(Optional) Tags to attach to the instance"
  type        = list(string)
  default     = []
}

variable "metadata" {
  description = <<-EOF
  (Optional) Metadata for VM-Series firewall.  The metadata is used to perform mgmt-interface-swap and for bootstrapping the VM-Series.
  
  Ex 1: Partial bootstrap to Panorama 
  ```
    metadata = {
      type                        = "dhcp-client"
      op-command-modes            = "mgmt-interface-swap"
      vm-auth-key                 = "012345601234560123456"
      panorama-server             = "1.1.1.1"
      dgname                      = "my-device-group"
      tplname                     = "my-template-stack"
      dhcp-send-hostname          = "yes"
      dhcp-send-client-id         = "yes"
      dhcp-accept-server-hostname = "yes"
      dhcp-accept-server-domain   = "yes"
    }
  ```
  
  Ex 2: Full configuration bootstrap from Google storage bucket.
  ```
    metadata = {
      mgmt-interface-swap                  = "enable"
      vmseries-bootstrap-gce-storagebucket = "your-bootstrap-bucket"
      ssh-keys                             = "admin:<your-public-key>"
    }
  ```
  EOF
  type        = map(string)
  default     = {}
}

variable "target_pool_self_links" {
  description = "(Optional) A list of target pool URLs to which the instance groups are added. Updating the target pools attribute does not affect existing VM-Series instances."
  type        = list(string)
  default     = null
}

variable "autoscaler_metrics" {
  description = "(Optional) A map with the keys being metrics identifiers (e.g. custom.googleapis.com/VMSeries/panSessionUtilization).  Each of the contained objects has attribute `target` which is a numerical threshold for a scale-out or a scale-in.  Each zonal group grows until it satisfies all the targets.  Additional optional attribute `type` defines the metric as either `GAUGE`, `DELTA_PER_SECOND`, or `DELTA_PER_MINUTE`.  For full specification, see the `metric` inside the [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_autoscaler)."
  default = {
    "custom.googleapis.com/VMSeries/panSessionUtilization" = {
      target = 70
    }
    "custom.googleapis.com/VMSeries/panSessionThroughputKbps" = {
      target = 700000
    }
  }
}

variable "cooldown_period" {
  description = "(Optional) The number of seconds that the autoscaler should wait before it starts collecting information from a new VM-Series. This prevents the autoscaler from collecting information when the VM-Series is initializing, during which the collected usage would not be reliable. Virtual machine initialization times might vary because of numerous factors."
  type        = number
  default     = 480
}

variable "scale_in_control_time_window_sec" {
  description = "(Optional) How far (in seconds) autoscaling should look into the past when scaling down."
  type        = number
  default     = 1800
}

variable "scale_in_control_replicas_fixed" {
  description = "(Optional) Fixed number of VM-Series instances that can be killed within the scale-in time window.  See `scale_in_control` in the [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_autoscaler)."
  type        = number
  default     = 1
}

variable "update_policy_type" {
  description = "(Optional) What to do when the underlying template changes (e.g. PAN-OS upgrade).  OPPORTUNISTIC is the only recommended value. Also PROACTIVE is allowed."
  type        = string
  default     = "OPPORTUNISTIC"
}

variable "named_ports" {
  description = <<-EOF
  (Optional) A list of named port configurations.    The name identifies the backend port to receive the traffic 
  from the global load balancers.

  ```
  named_ports = [
    {
      name = "http"
      port = "80"
    },
    {
      name = "app42"
      port = "4242"
    },
  ]
  ```
  EOF
  default     = []
}

variable "service_account_email" {
  description = "(Optional) IAM Service Account applied to the VM-Series instances."
  type        = string
  default     = null
}

