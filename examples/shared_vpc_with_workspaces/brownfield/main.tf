terraform {
  required_version = ">= 0.12, < 0.13"
}

provider "google" {
  version = "= 3.35"
}

#-----------------------------------------------------------------------------------------------
# The brownfield is the code that is normally not here.
module "brownfield" {
  source   = "../../../modules/vpc"
  networks = var.brownfield_networks
  region   = var.brownfield_networks_region
}

# FIXME: terraform destroy --target module.vpc.data.google_compute_network.this
# "0 destroyed"
# Now apply can gather the data.
