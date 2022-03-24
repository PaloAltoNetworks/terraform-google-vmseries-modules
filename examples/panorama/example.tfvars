# General
project_id = "gcp-gcs-pso"
project    = "gcp-gcs-pso"
region     = "us-central1"

# VPC
vpc_name          = "panorama-example-vpc"
subnet_name       = "panorama-example-subnet"
cidr              = "172.21.21.0/24"
allowed_sources   = ["0.0.0.0/0"]
private_static_ip = "172.21.21.111"
attach_public_ip  = true

# Panorama
panorama_name = "example-panorama"
ssh_key       = "example-sshkey"

