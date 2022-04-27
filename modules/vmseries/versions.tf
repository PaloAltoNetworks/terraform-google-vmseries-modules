terraform {
  required_version = ">= 0.12.29, < 2.0"

  required_providers {
    null   = { version = "~> 2.1" }
    google = { version = "~> 3.30" }
  }
}
