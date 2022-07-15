terraform {
  required_version = ">= 0.15.3, < 2.0"

  required_providers {
    null   = { version = "~> 3.1" }
    google = { version = "~> 3.30" }
  }
}
