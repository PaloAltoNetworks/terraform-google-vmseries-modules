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