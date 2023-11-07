variable "subnetworks" {
  description = <<-EOF
  A map containing subnetworks configuration. Subnets can be in different regions
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
  type        = any
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
  description = "MTU value for VPC Network"
  default     = 1460
  type        = number
  validation {
    condition     = var.mtu >= 1300 && var.mtu <= 8896
    error_message = "MTU Range must be between 1300 and 8896 !"
  }
}

variable "routing_mode" {
  description = "Type of network-wide routing mode to use. Possible types are : REGIONAL and GLOBAL."
  default     = "REGIONAL"
  type        = string
}

variable "firewall_rules" {
  description = <<-EOF
  A map containing firewall rules configuration.
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
}


variable "project_id" {
  description = "Project in which to create or look for VPCs and subnets"
  default     = null
  type        = string
}