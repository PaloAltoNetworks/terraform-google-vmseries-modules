# General
project     = "<PROJECT_ID>"
region      = "us-central1"
name_prefix = "example-"

# VPC

networks = {
  "panorama-vpc" = {
    create_network    = true
    create_subnetwork = true
    name              = "panorama-vpc"
    subnetwork_name   = "panorama-subnet"
    ip_cidr_range     = "172.21.21.0/24"
    allowed_sources   = ["1.1.1.1/32", "2.2.2.2/32"]
  }
}

# Panorama

panoramas = {
  "panorama-01" = {
    panorama_name     = "panorama-01"
    panorama_vpc      = "panorama-vpc"
    panorama_subnet   = "panorama-subnet"
    panorama_version  = "panorama-byol-1000"
    ssh_keys          = "admin:<ssh-rsa AAAA...>"
    attach_public_ip  = true
    private_static_ip = "172.21.21.2"

    log_disks = [
      {
        name = "panorama01-logdisk-1"
        type = "pd-ssd"
        size = "2000"
      },
      {
        name = "panorama01-logdisk-2"
        type = "pd-ssd"
        size = "2000"
      },
    ]
  }
}
