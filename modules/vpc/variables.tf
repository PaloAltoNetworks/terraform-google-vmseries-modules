variable "subnetworks" {
  description = <<-EOF
  A map containing subnetworks configuration. Subnets can belong to different regions.
  List of available attributes of each subnetwork entry:
  - `subnetwork_name` : Name of the subnetwork.
  - `create_subnetwork` : Boolean value to control the creation or reading of the subnetwork. If set to `true` - this will create the subnetwork. If set to `false` - this will read a subnet with provided information.
  - `ip_cidr_range` : A string that contains the subnetwork to create. Only IPv4 format is supported.
  - `region` : Region where to configure or import the subnet.

  Example:
  ```
  subnetworks = {
    my-sub = {
      subnetwork_name = "my-sub"
      create_subnetwork = true
      ip_cidr_range = "192.168.0.0/24"
      region = "us-east1"
    }
  }
  ```
  EOF
  default     = {}
  type = map(object({
    subnetwork_name   = string
    create_subnetwork = bool
    ip_cidr_range     = string
    region            = string
  }))
}

variable "name" {
  description = "The name of the created or already existing VPC Network."
  type        = string
}

variable "create_network" {
  description = <<-EOF
  A flag to indicate the creation or import of a VPC network.
  Setting this to `true` will create a new network managed by terraform.
  Setting this to `false` will try to read the existing network with those name and region settings.
  EOF
  default     = true
  type        = bool
}

variable "delete_default_routes_on_create" {
  description = <<-EOF
  A flag to indicate the deletion of the default routes at VPC creation.
  Setting this to `true` the default route `0.0.0.0/0` will be deleted upon network creation.
  Setting this to `false` the default route `0.0.0.0/0` will be not be deleted upon network creation.
  EOF
  default     = false
  type        = bool
}

variable "mtu" {
  description = <<-EOF
  MTU value for VPC Network. Acceptable values are between 1300 and 8896.
  EOF
  default     = 1460
  type        = number
  validation {
    condition     = var.mtu >= 1300 && var.mtu <= 8896
    error_message = "MTU Range must be between 1300 and 8896 !"
  }
}

variable "routing_mode" {
  description = <<-EOF
  Type of network-wide routing mode to use. Possible types are: REGIONAL and GLOBAL.
  REGIONAL routing mode will set the cloud routers to only advertise subnetworks within the same region as the router.
  GLOBAL routing mode will set the cloud routers to advertise all the subnetworks that belong to this network.
  EOF
  default     = "REGIONAL"
  type        = string
  validation {
    condition     = var.routing_mode == "REGIONAL" || var.routing_mode == "GLOBAL"
    error_message = "Routing mode must be either 'REGIONAL' or 'GLOBAL'."
  }
}

variable "firewall_rules" {
  description = <<-EOF
  A map containing each firewall rule configuration.
  Action of the firewall rule is always `allow`.
  The only possible direction of the firewall rule is `INGRESS`.

  List of available attributes of each firewall rule entry:
  - `name` : Name of the firewall rule.
  - `source_ranges` : (Optional) A list of strings containing the source IP ranges to be allowed on the firewall rule.
  - `source_tags` : (Optional) A list of strings containing the source network tags to be allowed on the firewall rule.
  - `source_service_accounts` : (Optional) A list of strings containg the source servce accounts to be allowed on the firewall rule.
  - `target_service_accounts` : (Optional) A list of strings containing the service accounts for which the firewall rule applies to.
  - `target_tags` : (Optional) A list of strings containing the network tags for which the firewall rule applies to. 
  - `allowed_protocol` : The protocol type to match in the firewall rule. Possible values are : tcp, udp, icmp, esp, ah, sctp, ipip, all
  - `ports` : A list of strings containing TCP or UDP port numbers to match in the firewall rule. This type of setting can be configured if allowing only TCP and UDP as protocols.
  - `priority` : (Optional) A priority value for the firewall rule. The lower the number - the more preffered the rule is.
  - `log_metadata` : (Optional) This field denotes whether to include or exclude metadata for firewall logs. Possible values are: `EXCLUDE_ALL_METADATA`, `INCLUDE_ALL_METADATA`.

  Example :
  ```
  firewall_rules = {
    firewall-rule-1 = {
      name = "first-rule"
      source_ranges = ["10.10.10.0/24", "1.1.1.0/24"]
      priority = "2000"
      target_tags = ["vmseries-firewalls"]
      allowed_protocol = "TCP"
      allowed_ports = ["443", "22"]
    }
  }
  ```
  EOF
  default     = {}
  type = map(object({
    name                    = string
    source_ranges           = optional(list(string))
    source_tags             = optional(list(string))
    source_service_accounts = optional(list(string))
    allowed_protocol        = string
    allowed_ports           = list(string)
    priority                = optional(string)
    target_service_accounts = optional(list(string))
    target_tags             = optional(list(string))
    log_metadata            = optional(string)
  }))
  validation {
    condition = length(var.firewall_rules) > 0 ? alltrue([
      for rule in var.firewall_rules : (
        (rule.source_ranges != null && rule.source_tags == null && rule.source_service_accounts == null) ||
        (rule.source_ranges == null && rule.source_tags != null && rule.source_service_accounts == null) ||
        (rule.source_ranges == null && rule.source_tags == null && rule.source_service_accounts != null)
      )
    ]) : true
    error_message = "Please select only one of the three options (source_ranges, source_tags, source_service_accounts) for each firewall rule."
  }
  validation {
    condition = length(var.firewall_rules) > 0 ? alltrue([
      for rule in var.firewall_rules : (
        (rule.target_tags != null && rule.target_service_accounts == null) ||
        (rule.target_tags == null && rule.target_service_accounts != null) ||
        (rule.target_tags == null && rule.target_service_accounts == null)
      )
    ]) : true
    error_message = "Please select only target_tags or target_service_accounts or neighter (apply to all instances in the network)."
  }
}


variable "project_id" {
  description = "Project in which to create or look for VPCs and subnets"
  default     = null
  type        = string
}