variable instances {
  description = "Definition of firewalls that will be deployed"
}

variable dependencies {
  default = []
  type    = list(string)
}
