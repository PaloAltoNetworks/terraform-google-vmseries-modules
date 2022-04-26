variable "mgmt_sources" {
  default = ["0.0.0.0/0"]
}

data "google_compute_zones" "available" {}

module "vpc" {
  source = "../../modules/vpc/"


  networks = {
    "${var.name_prefix}vpc" = {
      name            = "${var.name_prefix}vpc"
      subnetwork_name = "${var.name_prefix}subnet"
      ip_cidr_range   = "192.168.1.0/24"
      allowed_sources = var.mgmt_sources
    }
  }
}

locals {
  vpc    = module.vpc.networks["${var.name_prefix}vpc"].self_link
  subnet = try(module.vpc.subnetworks["${var.name_prefix}subnet"].self_link, null)
}

#  Google's own health checkers use a set of known address ranges
resource "google_compute_firewall" "builtin_healthchecks" {
  name          = "${var.name_prefix}vpc-builtin-healthchecks"
  network       = local.vpc
  direction     = "INGRESS"
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22"]
  # The "169.254.169.254/32" is also used, but it is always allowed anyway.

  allow {
    protocol = "all"
    ports    = []
  }
}

# Connect from outside to extlb.
resource "google_compute_firewall" "extlb" {
  name          = "${var.name_prefix}vpc-extlb"
  network       = local.vpc
  direction     = "INGRESS"
  source_ranges = var.mgmt_sources

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

# We need ssh to run our own verification code.
resource "google_compute_firewall" "ssh" {
  name          = "${var.name_prefix}vpc-ssh"
  network       = local.vpc
  direction     = "INGRESS"
  source_ranges = var.mgmt_sources

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
