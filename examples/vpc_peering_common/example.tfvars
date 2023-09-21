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
  mgmt = {
    create_network                  = true
    create_subnetwork               = true
    name                            = "fw-mgmt-vpc"
    subnetwork_name                 = "fw-mgmt-sub"
    ip_cidr_range                   = "10.10.10.0/28"
    allowed_sources                 = ["1.1.1.1/32"] # Replace 1.1.1.1/32 with your own souurce IP address for management purposes.
    delete_default_routes_on_create = false
    allowed_protocol                = "all"
    allowed_ports                   = []
  },
  untrust = {
    create_network                  = true
    create_subnetwork               = true
    name                            = "fw-untrust-vpc"
    subnetwork_name                 = "fw-untrust-sub"
    ip_cidr_range                   = "10.10.11.0/28"
    allowed_sources                 = ["35.191.0.0/16", "209.85.152.0/22", "209.85.204.0/22"]
    delete_default_routes_on_create = false
    allowed_protocol                = "all"
    allowed_ports                   = []
  },
  trust = {
    create_network                  = true
    create_subnetwork               = true
    name                            = "fw-trust-vpc"
    subnetwork_name                 = "fw-trust-sub"
    ip_cidr_range                   = "10.10.12.0/28"
    allowed_sources                 = ["192.168.0.0/16", "35.191.0.0/16", "130.211.0.0/22"]
    delete_default_routes_on_create = true
    allowed_protocol                = "all"
    allowed_ports                   = []
  },
  spoke1 = {
    create_network                  = true
    create_subnetwork               = true
    name                            = "spoke1-vpc"
    subnetwork_name                 = "spoke1-sub"
    ip_cidr_range                   = "192.168.1.0/28"
    allowed_sources                 = ["192.168.0.0/16", "35.235.240.0/20", "10.10.12.0/28"]
    delete_default_routes_on_create = true
    allowed_protocol                = "all"
    allowed_ports                   = []
  },
  spoke2 = {
    create_network                  = true
    create_subnetwork               = true
    name                            = "spoke2-vpc"
    subnetwork_name                 = "spoke2-sub"
    ip_cidr_range                   = "192.168.2.0/28"
    allowed_sources                 = ["192.168.0.0/16", "35.235.240.0/20", "10.10.12.0/28"]
    delete_default_routes_on_create = true
    allowed_protocol                = "all"
    allowed_ports                   = []
  }
}

# VPC Peerings

vpc_peerings = {
  trust-to-spoke1 = {
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
  },
  trust-to-spoke2 = {
    local_network = "fw-trust-vpc"
    peer_network  = "spoke2-vpc"

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

# Static routes
routes = {
  fw-default-trust = {
    name              = "fw-default-trust"
    destination_range = "0.0.0.0/0"
    network           = "fw-trust-vpc"
    lb_internal_key   = "internal-lb"
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
      trust_gcp_router_ip   = "10.10.12.1"
      untrust_gcp_router_ip = "10.10.11.1"
      private_network_cidr  = "192.168.0.0/16"
      untrust_loopback_ip   = "1.1.1.1/32" # This is placeholder IP - you must replace it on the vmseries config with the LB public IP address after the infrastructure is deployed
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
    bootstrap_bucket_key = "vmseries-bootstrap-bucket-01"
    bootstrap_options = {
      panorama-server = "1.1.1.1" # Modify this value as per deployment requirements
      dns-primary     = "8.8.8.8" # Modify this value as per deployment requirements
      dns-secondary   = "8.8.4.4" # Modify this value as per deployment requirements
    }
    bootstrap_template_map = {
      trust_gcp_router_ip   = "10.10.12.1"
      untrust_gcp_router_ip = "10.10.11.1"
      private_network_cidr  = "192.168.0.0/16"
      untrust_loopback_ip   = "1.1.1.1/32" # This is placeholder IP - you must replace it on the vmseries config with the LB public IP address after the infrastructure is deployed
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

# Spoke Linux VMs
linux_vms = {
  spoke1-vm = {
    linux_machine_type = "n2-standard-4"
    zone               = "us-east1-b"
    linux_disk_size    = "50" # Modify this value as per deployment requirements
    subnetwork         = "spoke1-sub"
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
    subnetwork         = "spoke2-sub"
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
  internal-lb = {
    name              = "internal-lb"
    health_check_port = "80"
    backends          = ["fw-vmseries-01", "fw-vmseries-02"]
    ip_address        = "10.10.12.5"
    subnetwork        = "fw-trust-sub"
    network           = "fw-trust-vpc"
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