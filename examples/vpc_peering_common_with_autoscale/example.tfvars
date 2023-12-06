# General
project     = "<PROJECT_ID>"
region      = "us-east4"
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
        name              = "fw-mgmt-sub"
        create_subnetwork = true
        ip_cidr_range     = "10.10.10.0/28"
        region            = "us-east4"
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
        name              = "fw-untrust-sub"
        create_subnetwork = true
        ip_cidr_range     = "10.10.11.0/28"
        region            = "us-east4"
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
  fw-trust-vpc = {
    vpc_name                        = "fw-trust-vpc"
    create_network                  = true
    delete_default_routes_on_create = true
    mtu                             = "1460"
    routing_mode                    = "REGIONAL"
    subnetworks = {
      fw-trust-sub = {
        name              = "fw-trust-sub"
        create_subnetwork = true
        ip_cidr_range     = "10.10.12.0/28"
        region            = "us-east4"
      }
    }
    firewall_rules = {
      allow-trust-ingress = {
        name             = "allow-trust-vpc"
        source_ranges    = ["192.168.0.0/16", "35.191.0.0/16", "130.211.0.0/22"]
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
      fw-spoke1-sub = {
        name              = "fw-spoke1-sub"
        create_subnetwork = true
        ip_cidr_range     = "192.168.1.0/28"
        region            = "us-east4"
      }
    }
    firewall_rules = {
      allow-spoke1-ingress = {
        name             = "allow-spoke1-vpc"
        source_ranges    = ["192.168.0.0/16", "35.235.240.0/20", "10.10.12.0/28"]
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
      fw-spoke2-sub = {
        name              = "fw-spoke2-sub"
        create_subnetwork = true
        ip_cidr_range     = "192.168.2.0/28"
        region            = "us-east4"
      }
    }
    firewall_rules = {
      allow-spoke2-ingress = {
        name             = "allow-spoke2-vpc"
        source_ranges    = ["192.168.0.0/16", "35.235.240.0/20", "10.10.12.0/28"]
        priority         = "1000"
        allowed_protocol = "all"
        allowed_ports    = []
      }
    }
  }
}

# VPC Peerings

vpc_peerings = {
  trust-to-spoke1 = {
    local_network_key = "fw-trust-vpc"
    peer_network_key  = "fw-spoke1-vpc"

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
    local_network_key = "fw-trust-vpc"
    peer_network_key  = "fw-spoke2-vpc"

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
    vpc_network_key   = "fw-trust-vpc"
    lb_internal_key   = "internal-lb"
  }
}

# Autoscale
autoscale_regional_mig = true

autoscale_common = {
  image            = "vmseries-flex-byol-1110"
  machine_type     = "n2-standard-4"
  min_cpu_platform = "Intel Cascade Lake"
  disk_type        = "pd-ssd"
  scopes = [
    "https://www.googleapis.com/auth/compute.readonly",
    "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
  ]
  tags               = ["vmseries-autoscale"]
  update_policy_type = "OPPORTUNISTIC"
  cooldown_period    = 480
}

autoscale = {
  fw-autoscale-common = {
    name = "fw-autoscale-common"
    zones = {
      zone1 = "us-east4-b"
      zone2 = "us-east4-c"
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
    service_account_key   = "sa-vmseries-01"
    min_vmseries_replicas = 2
    max_vmseries_replicas = 4
    create_pubsub_topic   = true
    autoscaler_metrics = {
      "custom.googleapis.com/VMSeries/panSessionUtilization" = {
        target = 70
      }
      "custom.googleapis.com/VMSeries/panSessionThroughputKbps" = {
        target = 700000
      }
    }
    bootstrap_options = {
      type                        = "dhcp-client"
      dhcp-send-hostname          = "yes"
      dhcp-send-client-id         = "yes"
      dhcp-accept-server-hostname = "yes"
      dhcp-accept-server-domain   = "yes"
      mgmt-interface-swap         = "enable"
      panorama-server             = "1.1.1.1"
      ssh-keys                    = "admin:<your_ssh_key>" # Replace this value with client data
    }
    network_interfaces = [
      {
        vpc_network_key  = "fw-untrust-vpc"
        subnetwork_key   = "fw-untrust-sub"
        create_public_ip = true
      },
      {
        vpc_network_key  = "fw-mgmt-vpc"
        subnetwork_key   = "fw-mgmt-sub"
        create_public_ip = true
      },
      {
        vpc_network_key = "fw-trust-vpc"
        subnetwork_key  = "fw-trust-sub"
      }
    ]
  }
}

# Spoke Linux VMs
linux_vms = {
  spoke1-vm = {
    linux_machine_type = "n2-standard-4"
    zone               = "us-east4-b"
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
    zone               = "us-east4-b"
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
  internal-lb = {
    name              = "internal-lb"
    health_check_port = "80"
    backends          = ["fw-autoscale-common"]
    subnetwork        = "fw-trust-sub"
    vpc_network_key   = "fw-trust-vpc"
    subnetwork_key    = "fw-trust-sub"
  }
}

# External Network Loadbalancer
lbs_external = {
  external-lb = {
    name     = "external-lb"
    backends = ["fw-autoscale-common"]
    rules = {
      all-ports = {
        ip_protocol = "L3_DEFAULT"
      }
    }
    http_health_check_port         = "80"
    http_health_check_request_path = "/php/login.php"
  }
}