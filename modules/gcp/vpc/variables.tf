variable name {
  type = string
}

variable subnetworks {
  type = map(any)
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

variable delete_default_routes_on_create {
  default = null
  type    = bool
}
