terraform {
  required_version = ">= 0.12, < 0.13"
}

provider "google" {
  version = "= 3.48"
}

data "google_compute_zones" "this" {}

variable allowed_sources {
  default = ["0.0.0.0/0"]
}

variable image_uri {
  default = null
}

# Firewall requires three VPC Networks on GCP, believe it or not!
# 
# Two of them pass the actual data, we call them untrust network and trust network.
# And one more dedicated to firewall's management traffic.

module "vpc" {
  source = "../../modules/vpc"
  networks = [
    {
      name            = "my-example3-untrust"
      subnetwork_name = "my-example3-untrust"
      ip_cidr_range   = "192.168.1.0/24"
      allowed_sources = var.allowed_sources
    },
    {
      name            = "my-example3-mgmt"
      subnetwork_name = "my-example3-mgmt"
      ip_cidr_range   = "192.168.0.0/24"
      allowed_sources = var.allowed_sources
    },
    {
      name            = "my-example3-trust"
      subnetwork_name = "my-example3-trust"
      ip_cidr_range   = "192.168.2.0/24"
    },
  ]
}

# Spawn the VM-series firewall as a Google Cloud Engine Instance.
module "vmseries" {
  source = "../../modules/vmseries"
  instances = {
    "my-example-fw01" = {
      name = "my-example3-fw01"
      zone = data.google_compute_zones.this.names[2]
      network_interfaces = [
        {
          subnetwork = module.vpc.subnetworks["my-example3-untrust"].self_link
          public_nat = true
        },
        {
          subnetwork = module.vpc.subnetworks["my-example3-mgmt"].self_link
          public_nat = true
        },
        {
          subnetwork = module.vpc.subnetworks["my-example3-trust"].self_link
          public_nat = false
          ip_address = "192.168.2.15"
        },
      ]
    }
  }
  ssh_key = "admin:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCbUVRz+1iNWsTVly/Xou2BUe8+ZEYmWymClLmFbQXsoFLcAGlK+NuixTq6joS+svuKokrb2Cmje6OyGG2wNgb8AsEvzExd+zbNz7Dsz+beSbYaqVjz22853+uY59CSrgdQU4a5py+tDghZPe1EpoYGfhXiD9Y+zxOIhkk+RWl2UKSW7fUe23UdXC4f+YbA0+Xy2l19g/tOVFgThHJn9FFdlQqlJC6a/0mWfudRNLCaiO5IbOlXIKvkLluWZ2GIMkr8uC5wldHyutF20EdAF9A4n72FssHCvB+WhrMCLspIgMfQA3ZMEfQ+/N5sh0c8vCZXV8GumlV4rN9xhjLXtTwf"

  image_uri = var.image_uri
}

output ssh_command {
  value = { for k, v in module.vmseries.nic1_ips : k => "ssh admin@${v}" }
}
