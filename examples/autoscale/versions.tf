terraform {
  required_version = ">= 1.2, < 2.0"
  required_providers {
    google = { version = "~> 4.58" }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
