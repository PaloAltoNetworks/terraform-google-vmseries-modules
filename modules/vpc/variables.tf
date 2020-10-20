variable networks {
}

variable region {
  description = "(Optional) GCP region for all the created subnetworks. Use a separate instance of this module to add subnetworks with another region (use `create_network=false`)."
  default     = null
  type        = string
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
