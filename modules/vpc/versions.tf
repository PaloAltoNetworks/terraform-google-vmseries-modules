terraform {
  required_version = ">= 0.12, < 0.13"
}

provider "google" {
  version = "~> 3.33" # 3.33 because of google_compute_firewall.log_config.metadata
}
