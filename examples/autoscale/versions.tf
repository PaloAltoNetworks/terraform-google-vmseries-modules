terraform {
  required_version = ">= 1.0.0, < 2.0"

  required_providers {
    google = { version = "~> 4.54" }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
