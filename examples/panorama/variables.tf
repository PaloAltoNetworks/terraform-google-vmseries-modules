# General
variable "project" {
  description = "The project name to deploy the infrastructure in to."
  type        = string
  default     = null
}
variable "region" {
  description = "The region into which to deploy the infrastructure in to"
  type        = string
  default     = "us-central1"
}
variable "name_prefix" {
  description = "A string to prefix resource namings"
  type        = string
  default     = ""
}

# VPC
variable "networks" {
  description = <<-EOF
    A map containing each network setting.

    Example of variable deployment :

    ```
    vpcs = {
      "panorama-vpc" = {
        vpc_name          = "panorama-vpc"
        subnet_name       = "panorama-subnet"
        cidr              = "172.21.21.0/24"
        allowed_sources   = ["1.1.1.1/32" , "2.2.2.2/32"]
        create_network    = true
        create_subnetwork = true
      }
    }
    ```

    For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/vpc#input_networks)

    Multiple keys can be added and will be deployed by the code
    EOF
}

# Panorama
variable "panoramas" {
  description = <<-EOF
    A map containing each panorama setting.

    Example of variable deployment :

    ```
    panoramas = {
      "panorama-01" = {
        panorama_name     = "panorama-01"
        panorama_vpc      = "panorama-vpc"
        panorama_subnet   = "example-panorama-subnet"
        panorama_version  = "panorama-byol-1000"
        ssh_keys          = "admin:<PUBLIC-KEY>"
        attach_public_ip  = true
        private_static_ip = "172.21.21.2"
      }
    }
    ```
  
    For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/panorama#inputs)

    Multiple keys can be added and will be deployed by the code
    EOF
}
