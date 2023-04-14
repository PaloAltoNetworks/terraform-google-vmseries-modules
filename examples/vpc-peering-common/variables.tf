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
  default     = "example-"
}
variable "location" {
  description = "Location in which the GCS Bucket will be deployed. Available locations can be found under https://cloud.google.com/storage/docs/locations."
  type        = string
  default     = "us"
}

#Service Account

variable "service_accounts" {
  description = <<-EOF
  A map containing each service account setting.

  Example of variable deployment :
    ```
  service_accounts = {
    "sa-vmseries-01" = {
      service_account_id = "sa-vmseries-01"
      display_name       = "VM-Series SA"
      roles = [
        "roles/compute.networkViewer",
        "roles/logging.logWriter",
        "roles/monitoring.metricWriter",
        "roles/monitoring.viewer",
        "roles/viewer"
      ]
    }
  }
  ```
  For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/iam_service_account#Inputs)

  Multiple keys can be added and will be deployed by the code

  EOF
  type        = map(any)
  default     = {}
}

#Bootstrap bucket

variable "bootstrap_buckets" {
  description = <<-EOF
  A map containing each bootstrap bucket setting.

  Example of variable deployment:

  ```
  bootstrap_buckets = {
    "vmseries-bootstrap-bucket-01" = {
      bucket_name_prefix = "bucket-01-"
      service_account    = "sa-vmseries-01"
      files = {
        "bootstrap_files/init-cfg.txt" = "config/init-cfg.txt"
        "bootstrap_files/authcodes"    = "license/authcodes"
      }
    }
  }
  ```

  For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/bootstrap#Inputs)

  Multiple keys can be added and will be deployed by the code

  EOF
  type        = map(any)
  default     = {}
}

#VPC

variable "networks" {
  description = <<-EOF
    A map containing each network setting.

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

    For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/vpc#input_networks)

    Multiple keys can be added and will be deployed by the code
    EOF
}

variable "vpc_peerings" {
  description = <<-EOF
  A map containing each VPC peering setting.

  Example of variable deployment :

  ```
  vpc_peerings = {
    "trust-to-spoke1" = {
      local_network = "fw-trust-vpc"
      peer_network  = "spoke1-vpc"

      local_export_custom_routes                = true
      local_import_custom_routes                = true
      local_export_subnet_routes_with_public_ip = true
      local_import_subnet_routes_with_public_ip = true

      peer_export_custom_routes                = true
      peer_import_custom_routes                = true
      peer_export_subnet_routes_with_public_ip = true
      peer_import_subnet_routes_with_public_ip = true
    }
  }
  ```
  For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/vpc-peering#inputs)

  Multiple keys can be added and will be deployed by the code
  EOF
  type        = map(any)
  default     = {}
}

#vmseries

variable "vmseries" {
  description = <<-EOF
  A map containing each individual vmseries setting.

  Example of variable deployment :

  ```
  vmseries = {
    "fw-vmseries-01" = {
      name             = "fw-vmseries-01"
      zone             = "us-east1-b"
      machine_type     = "n2-standard-4"
      min_cpu_platform = "Intel Cascade Lake"
      tags             = ["vmseries"]
      service_account  = "sa-vmseries-01"
      scopes = [
        "https://www.googleapis.com/auth/compute.readonly",
        "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
        "https://www.googleapis.com/auth/devstorage.read_only",
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring.write",
      ]
      bootstrap-bucket-key = "vmseries-bootstrap-bucket-01"
      bootstrap_options = {
        panorama-server = "1.1.1.1"
      }
      named_ports = [
        {
          name = "http"
          port = 80
        },
        {
          name = "https"
          port = 443
        }
      ]
      network_interfaces = [
        {
          subnetwork       = "fw-untrust-sub"
          private_ip       = "10.10.11.2"
          create_public_ip = true
        },
        {
          subnetwork       = "fw-mgmt-sub"
          private_ip       = "10.10.10.2"
          create_public_ip = true
        },
        {
          subnetwork = "fw-trust-sub"
          private_ip = "10.10.12.2"
        }
      ]
    }
  }
  ```
  For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/vmseries#inputs)

  Multiple keys can be added and will be deployed by the code

  EOF
}
variable "vmseries_common" {
  description = <<-EOF
  A map containing common vmseries setting.

  Example of variable deployment :

  ```
  vmseries_common = {
    ssh_keys       = "admin:mykey123"
    vmseries_image = "vmseries-flex-byol-1022h2"
    bootstrap_options = {
      type                = "dhcp-client"
      dns-primary         = "8.8.8.8"
      dns-secondary       = "8.8.4.4"
      mgmt-interface-swap = "enable"
    }
  }
  ``` 

  Bootstrap options can be moved between vmseries individual instance variable (`vmseries`) and this common vmserie variable (`vmseries_common`)
  EOF
}

#Load Balancers

variable "lbs_internal" {
  description = <<-EOF
  A map containing each internal loadbalancer setting.

  Example of variable deployment :

  ```
  lbs_internal = {
    "trust-lb" = {
      name              = "trust-lb"
      health_check_port = "22"
      backends          = ["fw-vmseries-01", "fw-vmseries-02"]
      ip_address        = "10.10.12.5"
      subnetwork        = "fw-trust-sub"
      network           = "fw-trust-vpc"
    }
  }
  ```
  For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/lb_internal#inputs)

  Multiple keys can be added and will be deployed by the code
  EOF
  type        = map(any)
  default     = {}
}
variable "lbs_external" {
  description = <<-EOF
  A map containing each external loadbalancer setting.

  Example of variable deployment :

  ```
lbs_external = {
  "external-lb" = {
    name      = "external-lb"
    instances = ["fw-vmseries-01", "fw-vmseries-02"]
    rules = {
      "http" = {
        port_range  = "80"
        ip_protocol = "TCP"
        ip_address  = ""
      },
      "https" = {
        port_range  = "443"
        ip_protocol = "TCP"
        ip_address  = ""
      },
      "icmp" = {
        port_range  = null
        ip_protocol = "ICMP" 
        ip_address  = ""
      }
    }
    http_health_check_port         = "80"
    http_health_check_request_path = "/"
  }
}
  ```
  For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/lb_external#inputs)

  Multiple keys can be added and will be deployed by the code
  EOF
  type        = map(any)
  default     = {}
}

variable "lbs_global_http" {
  description = <<-EOF
    A map containing each Global HTTP setting
  EOF
  type        = map(any)
  default     = {}
}

variable "routes" {
  description = <<-EOF
  A map containing each route setting. Note that you can only add routes using a next-hop type of internal load-balance rule.

  Example of variable deployment :

  ```
routes = {
  "default-route-trust" = {
    name = "fw-default-trust"
    destination_range = "0.0.0.0/0"
    network = "fw-trust-vpc"
    lb_internal_name = "internal-lb"
  }
}
  ```

  Multiple keys can be added and will be deployed by the code
  EOF
  type        = map(any)
  default     = {}
}

#Spoke VPCs Linux VMs

variable "linux_vms" {
  description = <<-EOF
  A map containing each Linux VM configuration that will be placed in SPOKE VPCs for testing purposes.
  EOF
  type        = map(any)
  default     = {}
}