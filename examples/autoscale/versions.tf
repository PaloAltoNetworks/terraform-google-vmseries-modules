terraform {
  required_version = ">= 1.3, < 2.0"
  required_providers {
    google = { version = "~> 4.58" }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}
