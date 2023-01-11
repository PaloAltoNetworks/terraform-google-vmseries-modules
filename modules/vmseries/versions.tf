terraform {
  required_version = ">= 1.0.0, < 2.0"
  required_providers {
    google = {
      version = "~> 4.46"
    }
    null = {
      version = "~> 3.2"
    }
  }
}
