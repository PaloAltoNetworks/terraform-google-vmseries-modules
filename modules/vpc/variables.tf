variable networks {
}

variable region {
  description =<<-EOF
    Explicit GCP region for all the created subnetworks. Use a separate instance of this module to add subnetworks with another region (use `create_network=false`).
    For Terraform 0.12 it's not recommended to use data.google_client_config.my.region to dynamically set this field. This will cause `terraform plan` to fail with:
    "cannot be determined until apply" error.
    EOF
}

variable allowed_sources {
  type    = list(string)
  default = []
}

variable allowed_protocol {
  default = "all"
}

variable allowed_ports {
  type    = list(string)
  default = []
}
