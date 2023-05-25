terraform {
  required_version = ">= 1.0, < 2.0"
}

provider "google" {
  project = var.project
  # region  = var.region
}