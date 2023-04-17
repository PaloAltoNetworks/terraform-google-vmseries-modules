terraform {
  required_version = ">= 1.0.0, < 2.0"

  required_providers {
    google = { version = "~> 3.48" }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
