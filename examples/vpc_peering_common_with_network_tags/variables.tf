# General
variable "project" {
  description = "The project name to deploy the infrastructure in to."
  type        = string
  default     = null
}
variable "region_1" {
  description = "The first region into which to deploy the infrastructure in to."
  type        = string
  default     = "us-east1"
}
variable "region_2" {
  description = "The second region into which to deploy the infrastructure in to."
  type        = string
  default     = "us-west1"
}
variable "name_prefix" {
  description = "A string to prefix resource namings."
  type        = string
  default     = "example-"
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

  Multiple keys can be added and will be deployed by the code.

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
      location           = "us"
      service_account    = "sa-vmseries-01"
    }
  }
  ```

  For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/bootstrap#Inputs)

  Multiple keys can be added and will be deployed by the code.

  EOF
  type        = map(any)
  default     = {}
}

#VPC

variable "networks_region_1" {
  description = <<-EOF
  A map containing each network setting for region_1.

  This map also contains the VPC networks creation for the deployment.

  Example of variable deployment :

  ```
  networks_region_1 = {
    mgmt = {
      create_network                  = true
      create_subnetwork               = true
      name                            = "fw-mgmt-vpc"
      subnetwork_name                 = "fw-mgmt-sub"
      ip_cidr_range                   = "10.10.10.0/28"
      allowed_sources                 = ["1.1.1.1/32"]
      delete_default_routes_on_create = false
      allowed_protocol                = "all"
      allowed_ports                   = []
    }
  }
  ```

  For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/vpc#input_networks)

  Multiple keys can be added and will be deployed by the code.
  EOF
}

variable "networks_region_2" {
  description = <<-EOF
  A map containing each network setting for region_2.

  In this map - only subnetworks are being  created, while referencing previously created VPC networks.

  Example of variable deployment :

  ```
  networks_region_2 = {
    mgmt = {
      create_network    = false
      create_subnetwork = true
      name              = "fw-mgmt-vpc"
      subnetwork_name   = "fw-mgmt-sub"
      ip_cidr_range     = "10.20.10.0/28"
    }
  }
  ```

  For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/vpc#input_networks)

  Multiple keys can be added and will be deployed by the code.
  EOF
}

variable "vpc_peerings" {
  description = <<-EOF
  A map containing each VPC peering setting.

  This is done only once since it's being called at the network level and not at the subnetwork which is dependent on the region.

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

  Multiple keys can be added and will be deployed by the code.
  EOF
  type        = map(any)
  default     = {}
}

variable "routes_region_1" {
  description = <<-EOF
  A map containing each route setting for region_1. Note that you can only add routes using a next-hop type of internal load-balance rule.

  The code automatically binds this route to an instance network tag that has the value of region_1 variable.

  Example of variable deployment :

  ```
  routes-region_1 = {
    fw-default-trust = {
      name              = "fw-default-trust"
      destination_range = "0.0.0.0/0"
      network           = "spoke1-vpc"
      lb_internal_key   = "internal-lb"
    }
  }
  ```

  Multiple keys can be added and will be deployed by the code.
  EOF
  type        = map(any)
  default     = {}
}

variable "routes_region_2" {
  description = <<-EOF
  A map containing each route setting for region_2. Note that you can only add routes using a next-hop type of internal load-balance rule.

  The code automatically binds this route to an instance network tag that has the value of region_2 variable.

  Example of variable deployment :

  ```
  routes-region_2 = {
    fw-default-trust = {
      name              = "fw-default-trust"
      destination_range = "0.0.0.0/0"
      network           = "spoke1-vpc"
      lb_internal_key   = "internal-lb"
    }
  }
  ```

  Multiple keys can be added and will be deployed by the code.
  EOF
  type        = map(any)
  default     = {}
}

#vmseries

variable "vmseries_common" {
  description = <<-EOF
  A map containing common vmseries setting.

  Example of variable deployment :

  ```
  vmseries_common = {
    ssh_keys       = "admin:ssh-rsa AAAAB3..."
    vmseries_image = "vmseries-flex-byol-1022h2"
    bootstrap_options = {
      type                = "dhcp-client"
      mgmt-interface-swap = "enable"
    }
  }
  ``` 

  Bootstrap options can be moved between vmseries individual instance variable (`vmseries`) and this common vmserie variable (`vmseries_common`).
  EOF
}
variable "vmseries_region_1" {
  description = <<-EOF
  A map containing each individual vmseries setting for region_1 instances.

  Example of variable deployment :

  ```
  vmseries_region_1 = {
    fw-vmseries-01 = {
      name = "fw-vmseries-01"
      zone = "us-east1-b"
      tags = ["vmseries"]
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
        dns-primary     = "8.8.8.8"
        dns-secondary   = "8.8.4.4"
      }
      bootstrap_template_map = {
        trust_gcp_router_ip   = "10.10.12.1"
        untrust_gcp_router_ip = "10.10.11.1"
        private_network_cidr  = "192.168.0.0/16"
        untrust_loopback_ip   = "1.1.1.1/32" # This is placeholder IP - you must replace it on the vmseries config with the LB public IP address (region_1) after the infrastructure is deployed
        trust_loopback_ip     = "10.10.12.5/32"
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
    },
    fw-vmseries-02 = {
      name = "fw-vmseries-02"
      zone = "us-east1-c"
      tags = ["vmseries"]
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
        dns-primary     = "8.8.8.8"
        dns-secondary   = "8.8.4.4"
      }
      bootstrap_template_map = {
        trust_gcp_router_ip   = "10.10.12.1"
        untrust_gcp_router_ip = "10.10.11.1"
        private_network_cidr  = "192.168.0.0/16"
        untrust_loopback_ip   = "1.1.1.1/32" # This is placeholder IP - you must replace it on the vmseries config with the LB public IP address (region_1) after the infrastructure is deployed
        trust_loopback_ip     = "10.10.12.5/32"
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
          private_ip       = "10.10.11.3"
          create_public_ip = true
        },
        {
          subnetwork       = "fw-mgmt-sub"
          private_ip       = "10.10.10.3"
          create_public_ip = true
        },
        {
          subnetwork = "fw-trust-sub"
          private_ip = "10.10.12.3"
        }
      ]
    }
  }
  ```
  For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/vmseries#inputs)

  The bootstrap_template_map contains variables that will be applied to the bootstrap template. Each firewall Day 0 bootstrap will be parametrised based on these inputs.
  Multiple keys can be added and will be deployed by the code.

  EOF
}

variable "vmseries_region_2" {
  description = <<-EOF
  A map containing each individual vmseries setting for region_2 instances.

  Example of variable deployment :

  ```
  vmseries_region_2 = {
    fw-vmseries-03 = {
      name = "fw-vmseries-03"
      zone = "us-west1-b"
      tags = ["vmseries"]
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
        dns-primary     = "8.8.8.8"
        dns-secondary   = "8.8.4.4"
      }
      bootstrap_template_map = {
        trust_gcp_router_ip   = "10.20.12.1"
        untrust_gcp_router_ip = "10.20.11.1"
        private_network_cidr  = "192.168.0.0/16"
        untrust_loopback_ip   = "2.2.2.2/32" # This is placeholder IP - you must replace it on the vmseries config with the LB public IP address (region_2) after the infrastructure is deployed
        trust_loopback_ip     = "10.20.12.5/32"
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
          private_ip       = "10.20.11.2"
          create_public_ip = true
        },
        {
          subnetwork       = "fw-mgmt-sub"
          private_ip       = "10.20.10.2"
          create_public_ip = true
        },
        {
          subnetwork = "fw-trust-sub"
          private_ip = "10.20.12.2"
        }
      ]
    },
    fw-vmseries-04 = {
      name = "fw-vmseries-04"
      zone = "us-west1-c"
      tags = ["vmseries"]
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
        dns-primary     = "8.8.8.8"
        dns-secondary   = "8.8.4.4"
      }
      bootstrap_template_map = {
        trust_gcp_router_ip   = "10.20.12.1"
        untrust_gcp_router_ip = "10.20.11.1"
        private_network_cidr  = "192.168.0.0/16"
        untrust_loopback_ip   = "2.2.2.2/32" # This is placeholder IP - you must replace it on the vmseries config with the LB public IP address (region_2) after the infrastructure is deployed
        trust_loopback_ip     = "10.20.12.5/32"
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
          private_ip       = "10.20.11.3"
          create_public_ip = true
        },
        {
          subnetwork       = "fw-mgmt-sub"
          private_ip       = "10.20.10.3"
          create_public_ip = true
        },
        {
          subnetwork = "fw-trust-sub"
          private_ip = "10.20.12.3"
        }
      ]
    }
  }
  ```
  For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/vmseries#inputs)

  The bootstrap_template_map contains variables that will be applied to the bootstrap template. Each firewall Day 0 bootstrap will be parametrised based on these inputs.
  Multiple keys can be added and will be deployed by the code.

  EOF
}

#Load Balancers

variable "lbs_internal_region_1" {
  description = <<-EOF
  A map containing each internal loadbalancer setting for region_1 instances.

  Example of variable deployment :

  ```
  lbs_internal_region_1 = {
    internal-lb = {
      name              = "internal-lb"
      health_check_port = "80"
      backends          = ["fw-vmseries-01", "fw-vmseries-02"]
      ip_address        = "10.10.12.5"
      subnetwork        = "fw-trust-sub"
      network           = "fw-trust-vpc"
    }
  }
  ```
  For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/lb_internal#inputs)

  Multiple keys can be added and will be deployed by the code.
  EOF
  type        = map(any)
  default     = {}
}

variable "lbs_internal_region_2" {
  description = <<-EOF
  A map containing each internal loadbalancer setting for region_2 instances.

  Example of variable deployment :

  ```
  lbs_internal_region_2 = {
    internal-lb = {
      name              = "internal-lb"
      health_check_port = "80"
      backends          = ["fw-vmseries-03", "fw-vmseries-04"]
      ip_address        = "10.20.12.5"
      subnetwork        = "fw-trust-sub"
      network           = "fw-trust-vpc"
    }
  }
  ```
  For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/lb_internal#inputs)

  Multiple keys can be added and will be deployed by the code.
  EOF
  type        = map(any)
  default     = {}
}

variable "lbs_external_region_1" {
  description = <<-EOF
  A map containing each external loadbalancer setting for region_1 instances.

  Example of variable deployment :

  ```
  lbs_external_region_1 = {
    external-lb = {
      name     = "external-lb"
      backends = ["fw-vmseries-01", "fw-vmseries-02"]
      rules = {
        all-ports-region_1 = {
          ip_protocol = "L3_DEFAULT"
        }
      }
      http_health_check_port         = "80"
      http_health_check_request_path = "/php/login.php"
    }
  }
  ```
  For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/lb_external#inputs)

  Multiple keys can be added and will be deployed by the code.
  EOF
  type        = map(any)
  default     = {}
}

variable "lbs_external_region_2" {
  description = <<-EOF
  A map containing each external loadbalancer setting for region_2 instances.

  Example of variable deployment :

  ```
  lbs_external_region_2 = {
    external-lb = {
      name     = "external-lb"
      backends = ["fw-vmseries-03", "fw-vmseries-04"]
      rules = {
        all-ports-region_2 = {
          ip_protocol = "L3_DEFAULT"
        }
      }
      http_health_check_port         = "80"
      http_health_check_request_path = "/php/login.php"
    }
  }
  ```
  For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/lb_external#inputs)

  Multiple keys can be added and will be deployed by the code.
  EOF
  type        = map(any)
  default     = {}
}

#Spoke VPCs Linux VMs

variable "linux_vms_region_1" {
  description = <<-EOF
  A map containing each Linux VM configuration in region_1 that will be placed in spoke VPC network for testing purposes.

  Example of varaible deployment:

  ```
  linux_vms_region_1 = {
    spoke1-vm = {
      linux_machine_type = "n2-standard-4"
      zone               = "us-east1-b"
      linux_disk_size    = "50"
      subnetwork         = "spoke1-sub"
      private_ip         = "192.168.1.2"
      scopes = [
        "https://www.googleapis.com/auth/compute.readonly",
        "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
        "https://www.googleapis.com/auth/devstorage.read_only",
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring.write",
      ]
      service_account = "sa-linux-01"
    }
  }
  ```
  EOF
  type        = map(any)
  default     = {}
}

variable "linux_vms_region_2" {
  description = <<-EOF
  A map containing each Linux VM configuration in region_2 that will be placed in spoke VPC network for testing purposes.

  Example of varaible deployment:

  ```
  linux_vms_region_2 = {
    spoke2-vm = {
      linux_machine_type = "n2-standard-4"
      zone               = "us-west1-b"
      linux_disk_size    = "50"
      subnetwork         = "spoke1-sub"
      private_ip         = "192.168.2.2"
      scopes = [
        "https://www.googleapis.com/auth/compute.readonly",
        "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
        "https://www.googleapis.com/auth/devstorage.read_only",
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring.write",
      ]
      service_account = "sa-linux-01"
    }
  }
  ```
  EOF
  type        = map(any)
  default     = {}
}