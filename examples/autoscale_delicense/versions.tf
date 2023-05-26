terraform {
  required_version = ">= 1.3.9, < 2.0"
}

provider "google" {
  project = var.project
  region  = var.region
}