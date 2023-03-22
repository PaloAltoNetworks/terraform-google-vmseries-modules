terraform {
  required_version = ">= 1.0.0, < 2.0"

  required_providers {
    null   = { version = "~> 3.1" }
    random = { version = "~> 3.1" }
    google = { version = "~> 4.54" }
  }
}

provider "google" {
  project = var.project
  region  = var.region
}
