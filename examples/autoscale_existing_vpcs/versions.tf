terraform {
  required_version = ">= 0.15.3, < 2.0"

  required_providers {
    google = { version = "~> 3.48" }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
