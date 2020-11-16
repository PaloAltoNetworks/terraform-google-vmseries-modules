terraform {
  required_providers {
    null   = { version = "~> 2.1" }
    random = { version = "~> 2.3" }
    google = { version = "~> 3.30" }
    # google = { version = "~> 3.38" }  # because uniform_bucket_level_access
  }
}
