terraform {
  required_version = ">= 0.12, < 0.13"
}

provider "google" {
  version = "= 3.48"
}

# Dedicated IAM service account for running GCP instances of Palo Alto Networks VM-Series.
# Applying this module requires IAM roles Security Admin and Service Account Admin or their equivalents.
module "iam_service_account" {
  source             = "../../modules/iam_service_account/"
  service_account_id = "iamexample-panw-fw-sa"
}

# Create a bucket for bootstrapping a firewall VM.
# (The VM itself is out of scope here.)
module "bootstrap" {
  source = "../../modules/bootstrap/"

  service_account = module.iam_service_account.email
  files           = {}
}

# Dedicated IAM service account for authenticating Panorama's GCP Plugin 2.0.
# This account is not for running an instance of Panorama. Instead, set it up in:
#   PanOS WebUI -> Panorama tab -> Plugins -> GCP -> Setup, and
#   PanOS WebUI -> Panorama tab -> Plugins -> GCP -> Autoscaling
#
# Source: https://docs.paloaltonetworks.com/vm-series/10-0/vm-series-deployment/set-up-the-vm-series-firewall-on-google-cloud-platform/autoscaling-on-google-cloud-platform/autoscaling-components-for-gcp
module "iam_service_account_panorama" {
  source             = "../../modules/iam_service_account/"
  service_account_id = "iamexample-panorama-sa"
  display_name       = "Palo Alto Networks Panorama GCP Plugin Service Account"
  roles = [
    "roles/compute.viewer",
    "roles/deploymentmanager.viewer",
    "roles/pubsub.admin",
  ]
}
