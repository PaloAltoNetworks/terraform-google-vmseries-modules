terraform {
  required_version = ">=1.2, < 2.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.74, < 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.74, < 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
  }
}
