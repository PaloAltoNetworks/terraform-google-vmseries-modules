terraform {
  required_version = ">= 0.12, < 0.13"
}

provider "google" {
  version = "= 3.35"
}

# The brownfield is the pre-existing infrastructure.
# Although we create it as Terraform objects, the rest of Terraform code doesn't use them.
# The same objects can also be created in Google Cloud Console or by API.

# The VPC Networks.
module "brownfield" {
  source   = "../../../modules/vpc"
  networks = var.brownfield_networks
  region   = var.brownfield_networks_region
}

# The pre-existing public IP address. 
# We need to migrate it onto PANW VM-Series.
resource "google_compute_address" "this" {
  name   = "my-example4-ip"
  region = var.brownfield_networks_region
}

output "public_ip_allocatted" {
  value = google_compute_address.this.address
}
