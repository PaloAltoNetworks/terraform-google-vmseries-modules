# General
project     = "<PROJECT_ID>"
region      = "us-east1" # Modify this value as per deployment requirements
name_prefix = ""

# Service accounts

service_accounts = {
  sa-vmseries-01 = {
    service_account_id = "sa-vmseries-01"
    display_name       = "VM-Series SA"
    roles = [
      "roles/compute.networkViewer",
      "roles/logging.logWriter",
      "roles/monitoring.metricWriter",
      "roles/monitoring.viewer",
      "roles/viewer"
    ]
  },
  sa-linux-01 = {
    service_account_id = "sa-linux-01"
    display_name       = "Linux VMs SA"
    roles = [
      "roles/compute.networkViewer",
      "roles/logging.logWriter",
      "roles/monitoring.metricWriter",
      "roles/monitoring.viewer",
      "roles/viewer"
    ]
  }
}

bootstrap_buckets = {
  vmseries-bootstrap-bucket-01 = {
    bucket_name_prefix  = "bucket-01-"
    location            = "us"
    service_account_key = "sa-vmseries-01"
  }
}

# VPC

networks = {
  fw-mgmt-vpc = {
    vpc_name                        = "fw-mgmt-vpc"
    create_network                  = true
    delete_default_routes_on_create = false
    mtu                             = "1460"
    routing_mode                    = "REGIONAL"
    subnetworks = {
      fw-mgmt-sub = {
        subnetwork_name   = "fw-mgmt-sub"
        create_subnetwork = true
        ip_cidr_range     = "10.10.10.0/28"
        region            = "us-east1"
      }
    }
    firewall_rules = {
      allow-mgmt-ingress = {
        name             = "allow-mgmt-vpc"
        source_ranges    = ["1.1.1.1/32"] # Replace 1.1.1.1/32 with your own souurce IP address for management purposes.
        priority         = "1000"
        allowed_protocol = "all"
        allowed_ports    = []
      }
    }
  },
  fw-untrust-vpc = {
    vpc_name                        = "fw-untrust-vpc"
    create_network                  = true
    delete_default_routes_on_create = false
    mtu                             = "1460"
    routing_mode                    = "REGIONAL"
    subnetworks = {
      fw-untrust-sub = {
        subnetwork_name   = "fw-untrust-sub"
        create_subnetwork = true
        ip_cidr_range     = "10.10.11.0/28"
        region            = "us-east1"
      }
    }
    firewall_rules = {
      allow-untrust-ingress = {
        name             = "allow-untrust-vpc"
        source_ranges    = ["35.191.0.0/16", "209.85.152.0/22", "209.85.204.0/22", "1.1.1.1/32"] # Replace 1.1.1.1/32 with your own souurce IP address for management purposes.
        priority         = "1000"
        allowed_protocol = "all"
        allowed_ports    = []
      }
    }
  },
  fw-spoke1-vpc = {
    vpc_name                        = "fw-spoke1-vpc"
    create_network                  = true
    delete_default_routes_on_create = true
    mtu                             = "1460"
    routing_mode                    = "REGIONAL"
    subnetworks = {
      fw-spoke1-inside-sub = {
        subnetwork_name   = "fw-spoke1-inside-sub"
        create_subnetwork = true
        ip_cidr_range     = "10.10.12.0/28"
        region            = "us-east1"
      },
      fw-spoke1-sub = {
        subnetwork_name   = "fw-spoke1-sub"
        create_subnetwork = true
        ip_cidr_range     = "192.168.1.0/28"
        region            = "us-east1"
      }
    }
    firewall_rules = {
      allow-spoke1-ingress = {
        name             = "allow-spoke1-vpc"
        source_ranges    = ["192.168.0.0/16", "35.235.240.0/20", "35.191.0.0/16", "130.211.0.0/22", "10.10.12.0/28"]
        priority         = "1000"
        allowed_protocol = "all"
        allowed_ports    = []
      }
    }
  },
  fw-spoke2-vpc = {
    vpc_name                        = "fw-spoke2-vpc"
    create_network                  = true
    delete_default_routes_on_create = true
    mtu                             = "1460"
    routing_mode                    = "REGIONAL"
    subnetworks = {
      fw-spoke2-inside-sub = {
        subnetwork_name   = "fw-spoke2-inside-sub"
        create_subnetwork = true
        ip_cidr_range     = "10.10.13.0/28"
        region            = "us-east1"
      },
      fw-spoke2-sub = {
        subnetwork_name   = "fw-spoke2-sub"
        create_subnetwork = true
        ip_cidr_range     = "192.168.2.0/28"
        region            = "us-east1"
      }
    }
    firewall_rules = {
      allow-spoke2-ingress = {
        name             = "allow-spoke2-vpc"
        source_ranges    = ["192.168.0.0/16", "35.235.240.0/20", "35.191.0.0/16", "130.211.0.0/22", "10.10.12.0/28"]
        priority         = "1000"
        allowed_protocol = "all"
        allowed_ports    = []
      }
    }
  }
}

# Static routes
routes = {
  fw-default-spoke1 = {
    name              = "fw-default-spoke1"
    destination_range = "0.0.0.0/0"
    vpc_network_key   = "fw-spoke1-vpc"
    lb_internal_key   = "internal-lb-spoke1"
  },
  fw-default-spoke2 = {
    name              = "fw-default-spoke2"
    destination_range = "0.0.0.0/0"
    vpc_network_key   = "fw-spoke2-vpc"
    lb_internal_key   = "internal-lb-spoke2"
  }
}

# VM-Series

vmseries_common = {
  ssh_keys            = "admin:<YOUR_SSH_KEY>"
  vmseries_image      = "vmseries-flex-byol-1022h2"
  machine_type        = "n2-standard-4"
  min_cpu_platform    = "Intel Cascade Lake"
  service_account_key = "sa-vmseries-01"
  bootstrap_options = {
    type                = "dhcp-client"
    mgmt-interface-swap = "enable"
  }
}

vmseries = {
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
    bootstrap_bucket_key = "vmseries-bootstrap-bucket-01"
    bootstrap_options = {
      panorama-server = "1.1.1.1" # Modify this value as per deployment requirements
      dns-primary     = "8.8.8.8" # Modify this value as per deployment requirements
      dns-secondary   = "8.8.4.4" # Modify this value as per deployment requirements
    }
    bootstrap_template_map = {
      spoke1_gcp_router_ip   = "10.10.12.1"
      spoke2_gcp_router_ip   = "10.10.13.1"
      untrust_gcp_router_ip = "10.10.11.1"
      private_network_cidr  = "192.168.0.0/16"
      untrust_loopback_ip   = "1.1.1.1/32" # This is placeholder IP - you must replace it on the vmseries config with the LB public IP address after the infrastructure is deployed
      spoke1_loopback_ip     = "10.10.12.5/32"
      spoke2_loopback_ip     = "10.10.13.5/32"
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
        vpc_network_key  = "fw-untrust-vpc"
        subnetwork_key   = "fw-untrust-sub"
        private_ip       = "10.10.11.2"
        create_public_ip = true
      },
      {
        vpc_network_key  = "fw-mgmt-vpc"
        subnetwork_key   = "fw-mgmt-sub"
        private_ip       = "10.10.10.2"
        create_public_ip = true
      },
      {
        vpc_network_key = "fw-spoke1-vpc"
        subnetwork_key  = "fw-spoke1-inside-sub"
        private_ip      = "10.10.12.2"
      },
      {
        vpc_network_key = "fw-spoke2-vpc"
        subnetwork_key  = "fw-spoke2-inside-sub"
        private_ip      = "10.10.13.2"
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
    bootstrap_bucket_key = "vmseries-bootstrap-bucket-01"
    bootstrap_options = {
      panorama-server = "1.1.1.1" # Modify this value as per deployment requirements
      dns-primary     = "8.8.8.8" # Modify this value as per deployment requirements
      dns-secondary   = "8.8.4.4" # Modify this value as per deployment requirements
    }
    bootstrap_template_map = {
      spoke1_gcp_router_ip   = "10.10.12.1"
      spoke2_gcp_router_ip   = "10.10.13.1"
      untrust_gcp_router_ip = "10.10.11.1"
      private_network_cidr  = "192.168.0.0/16"
      untrust_loopback_ip   = "1.1.1.1/32" # This is placeholder IP - you must replace it on the vmseries config with the LB public IP address after the infrastructure is deployed
      spoke1_loopback_ip     = "10.10.12.5/32"
      spoke2_loopback_ip     = "10.10.13.5/32"
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
        vpc_network_key  = "fw-untrust-vpc"
        subnetwork_key   = "fw-untrust-sub"
        private_ip       = "10.10.11.3"
        create_public_ip = true
      },
      {
        vpc_network_key  = "fw-mgmt-vpc"
        subnetwork_key   = "fw-mgmt-sub"
        private_ip       = "10.10.10.3"
        create_public_ip = true
      },
      {
        vpc_network_key = "fw-spoke1-vpc"
        subnetwork_key  = "fw-spoke1-inside-sub"
        private_ip      = "10.10.12.3"
      },
      {
        vpc_network_key = "fw-spoke2-vpc"
        subnetwork_key  = "fw-spoke2-inside-sub"
        private_ip      = "10.10.13.3"
      }
    ]
  }
}

# Spoke Linux VMs
linux_vms = {
  spoke1-vm = {
    linux_machine_type = "n2-standard-4"
    zone               = "us-east1-b"
    linux_disk_size    = "50" # Modify this value as per deployment requirements
    vpc_network_key    = "fw-spoke1-vpc"
    subnetwork_key     = "fw-spoke1-sub"
    private_ip         = "192.168.1.2"
    scopes = [
      "https://www.googleapis.com/auth/compute.readonly",
      "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
    ]
    service_account_key = "sa-linux-01"
  },
  spoke2-vm = {
    linux_machine_type = "n2-standard-4"
    zone               = "us-east1-b"
    linux_disk_size    = "50" # Modify this value as per deployment requirements
    vpc_network_key    = "fw-spoke2-vpc"
    subnetwork_key     = "fw-spoke2-sub"
    private_ip         = "192.168.2.2"
    scopes = [
      "https://www.googleapis.com/auth/compute.readonly",
      "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
    ]
    service_account_key = "sa-linux-01"
  }
}

# Internal Network Loadbalancer
lbs_internal = {
  internal-lb-spoke1 = {
    name              = "internal-lb-spoke1"
    health_check_port = "80"
    backends          = ["fw-vmseries-01", "fw-vmseries-02"]
    ip_address        = "10.10.12.5"
    vpc_network_key   = "fw-spoke1-vpc"
    subnetwork_key    = "fw-spoke1-inside-sub"
  },
  internal-lb-spoke2 = {
    name              = "internal-lb-spoke2"
    health_check_port = "80"
    backends          = ["fw-vmseries-01", "fw-vmseries-02"]
    ip_address        = "10.10.13.5"
    vpc_network_key   = "fw-spoke2-vpc"
    subnetwork_key    = "fw-spoke2-inside-sub"
  }
}

# External Network Loadbalancer
lbs_external = {
  external-lb = {
    name     = "external-lb"
    backends = ["fw-vmseries-01", "fw-vmseries-02"]
    rules = {
      all-ports = {
        ip_protocol = "L3_DEFAULT"
      }
    }
    http_health_check_port         = "80"
    http_health_check_request_path = "/php/login.php"
  }
}