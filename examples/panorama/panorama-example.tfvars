# General
project = "<PROJECT_ID>"
region  = "us-central1"

# VPC

vpcs = {
  "panorama-vpc" = {
    vpc_name          = "panorama-vpc"
    subnet_name       = "example-panorama-subnet"
    cidr              = "172.21.21.0/24"
    allowed_sources   = ["1.1.1.1/32", "2.2.2.2/32"]
    create_network    = true
    create_subnetwork = true
  }
}

# Panorama

panoramas = {
  "panorama-01" = {
    panorama_name     = "panorama-01"
    panorama_vpc      = "panorama-vpc"
    panorama_subnet   = "example-panorama-subnet"
    panorama_version  = "panorama-byol-1000"
    ssh_keys          = "admin:<ssh-rsa AAAA...>"
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
