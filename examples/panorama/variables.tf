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

# VPC
variable "vpcs" {
  description = <<-EOF
    A map containing each network setting:

    Available options :
    - `vpc_name`          - (Required|string) VPC name to create or read from
    - `subnet_name`       - (Required|string) Subnet name to create or read from
    - `cidr`              - (Required|string) CIDR to create or read from
    - `allowed_sources`   - (Optional|list) A list of allowed subnets/hosts for which ingress firewall rules will be created with "Allow" statement and "all" ports for that specific VPC
    - `create_network`    - (Required|boolean) A flag that indicates if whether to create the VPC or read from an existing one
    - `create_subnetwork` - (Required|boolean) A flag that indicates if whether to create the subnetwork or read from and existing one
    Example of variable deployment :

    ```
    vpcs = {
      "panorama-vpc" = {
        vpc_name          = "panorama-vpc"
        subnet_name       = "example-panorama-subnet"
        cidr              = "172.21.21.0/24"
        allowed_sources   = ["1.1.1.1/32" , "2.2.2.2/32"]
        create_network    = true
        create_subnetwork = true
      }
    }
    ```

    Multiple keys can be added and will be deployed by the code
    EOF
}

# Panorama
variable "panoramas" {
  description = <<-EOF
    A map containing each panorama setting:

    Available options :
    - `panorama_name`          - (Required|string) Name of the panorama instance
    - `panorama_vpc`           - (Required|string) VPC name of the instance where panorama will be deployed. Must be created/imported via "vpcs" variable
    - `panorama_subnet`        - (Required|string) Subnet name of the instance where panorama will be deployed. Must be created/imported via "vpcs" variable
    - `panorama_version`       - (Required|string) Panorama version available in "paloaltonetworksgcp-public" project
    - `ssh_keys`               - (Required|string) SSH keys that will be used for SSH connectivity
    - `attach_public_ip`       - (Required|boolean) Flag to to indicate whether to create a public IP address for the management interface or not
    - `private_static_ip`      - (Required|string) Static IP address pointed here will be created. It must be a parte of VPC and Subnet cread/imported via "vpcs" variable
    - `log_disks`              - (Required,list) A list of additional disks to add to the panorama for logging purposes.
      - Example of logging disk :
      ```
        log_disks = [
          {
            name = "example-panorama-disk-1"
            type = "pd-ssd"
            size = "2000"
          },
          {
            name = "example-panorama-disk-2"
            type = "pd-ssd"
            size = "2000"
          },
        ]
      ```

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

        log_disks = [
          {
            name = "example-panorama-disk-1"
            type = "pd-ssd"
            size = "2000"
          },
          {
            name = "example-panorama-disk-2"
            type = "pd-ssd"
            size = "2000"
          },
        ]
      }
    }
    ```

    Multiple keys can be added and will be deployed by the code
    EOF
}