# General
project_id = "example-panorama"
project    = "example-panorama"
region     = "us-central1"

# VPC
vpc_name          = "example-panorama-vpc"
subnet_name       = "example-panorama-subnet"
cidr              = "172.21.21.0/24"
allowed_sources   = ["0.0.0.0/0"]
private_static_ip = "172.21.21.111"
attach_public_ip  = true

# Panorama
panorama_name    = "example-panorama"
panorama_version = "panorama-byol-1000"
ssh_keys         = "admin:<public-key>"
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

