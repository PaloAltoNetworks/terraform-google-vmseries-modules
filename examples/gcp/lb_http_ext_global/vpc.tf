terraform {
  required_version = ">= 0.12, < 0.13"
}

provider "google" {
  version = "= 3.30"
}

variable mgmt_sources {
  default = ["0.0.0.0/0"]
}

variable region {
  default = "europe-west4"
}

data "google_compute_zones" "available" {
  region = var.region
}

module "vpc" {
  source = "../../../modules/gcp/vpc/"

  vpc             = "my-vpc"
  subnets         = ["my-subnet"]
  cidrs           = ["192.168.1.0/24"]
  regions         = [var.region]
  allowed_sources = var.mgmt_sources
}

#  Google's own health checkers use a set of known address ranges
resource "google_compute_firewall" "builtin_healthchecks" {
  name          = "my-vpc-builtin-healthchecks"
  network       = "my-vpc"
  direction     = "INGRESS"
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22"]
  # The "169.254.169.254/32" is also used, but it is always allowed anyway.

  allow {
    protocol = "all"
    ports    = []
  }
}

module "vm" {
  source      = "../../../modules/gcp/vm/"
  names       = ["my-vm01", "my-vm02"]
  zones       = [data.google_compute_zones.available.names[0], data.google_compute_zones.available.names[1]]
  subnetworks = ["my-subnet", "my-subnet"]

  ## Any image will do, if only it exposes on port 80 the http url `/`:
  image        = "https://console.cloud.google.com/compute/imagesDetail/projects/nginx-public/global/images/nginx-plus-centos7-developer-v2019070118"
  machine_type = "g1-small"

  ## The part before the colon is the ssh user name. The part after is intended to be replaced with your own ssh-rsa public key.
  ssh_key = "demo:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCbUVRz+1iNWsTVly/Xou2BUe8+ZEYmWymClLmFbQXsoFLcAGlK+NuixTq6joS+svuKokrb2Cmje6OyGG2wNgb8AsEvzExd+zbNz7Dsz+beSbYaqVjz22853+uY59CSrgdQU4a5py+tDghZPe1EpoYGfhXiD9Y+zxOIhkk+RWl2UKSW7fUe23UdXC4f+YbA0+Xy2l19g/tOVFgThHJn9FFdlQqlJC6a/0mWfudRNLCaiO5IbOlXIKvkLluWZ2GIMkr8uC5wldHyutF20EdAF9A4n72FssHCvB+WhrMCLspIgMfQA3ZMEfQ+/N5sh0c8vCZXV8GumlV4rN9xhjLXtTwf"

  create_instance_group = true
}
