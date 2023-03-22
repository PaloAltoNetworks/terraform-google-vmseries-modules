terraform {
  required_version = ">= 1.0.0, < 2.0"
}

provider "google" {
  project = var.project_id
  region  = var.region
}