terraform {
  required_version = ">= 0.15.3, < 2.0"

  required_providers {
    null   = { version = "~> 3.1" }
    random = { version = "~> 3.1" }
    google = { version = "~> 3.48" }
  }
}

provider "google" {
  project = var.project
  region  = var.region
}
