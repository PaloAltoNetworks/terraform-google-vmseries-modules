terraform {
  required_version = ">= 0.12, < 0.13"
}

provider "google" {
  version = "= 3.48"
}

# The brownfield or, in other words, the pre-existing infrastructure.
# Although we create it as Terraform objects, the rest of our code does not
# refer to them as to objects. Instead it treats them as pre-existing
# objects that could have been created as well manually with Google Cloud Console
# or with gcloud command.

# The VPC Networks.
module "brownfield" {
  source   = "../../../modules/vpc"
  networks = var.brownfield_networks
  region   = var.brownfield_networks_region
}

# The pre-existing public IP address. 
# Pretended goal: migrate it onto PANW VM-Series.
resource "google_compute_address" "this" {
  name   = "my-example4-ip"
  region = var.brownfield_networks_region
}

output "public_ip_allocated" {
  value = google_compute_address.this.address
}
