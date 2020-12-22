# Architecture Decision Record

## Create Multiple VPC Networks

How to create multiple VPC networks on Terraform 0.12 where `for_each` is only possible for a `resource` but not for a `module`.

Decision is to use: ...TODO, fill before merge...

Possibilities, subjectively worst to best:

### Map, Keys Are Names

```terraform
# us-central1.tfvars
map = {
  "acme-untrust" = {
      network_name    = "acme-untrust"
      subnetwork_name = "acme-untrust-us-central1"
  }
  "acme-mgmt" = {
      network_name    = "acme-mgmt"
      subnetwork_name = "acme-mgmt-us-central1"
  }
  "acme-panorama" = {
      network_name    = "acme-panorama"
      subnetwork_name = "acme-panorama-us-central1"
  }
  "acme-trust" = {
      network_name      = "acme-trust"
      subnetwork_name   = "acme-trust-us-central1"
      create_network    = false  # brownfield!
      create_subnetwork = false  # brownfield!
  }
}

subnetwork_keys_for_firewalls = [
    "acme-untrust-us-central1",
    "acme-mgmt-us-central1",
    "acme-trust-us-central1",
]

subnetwork_key_for_inbound_addresses = "acme-untrust-us-central1"

# australia-southeast1.tfvars
map = {
  "acme-untrust" = {
      network_name    = "acme-untrust"
      subnetwork_name = "acme-untrust-australia-southeast1"
      create_network  = false  # sic! us-central1 created!
  }
  "acme-mgmt" = {
      network_name    = "acme-mgmt"
      subnetwork_name = "acme-mgmt-australia-southeast1"
      create_network  = false  # sic! us-central1 created!
  }
  "acme-panorama" = {
      network_name    = "acme-panorama"
      subnetwork_name = "acme-panorama-australia-southeast1"
      create_network  = false  # sic! us-central1 created!
  }
  "acme-trust" = {
      network_name      = "acme-trust"
      subnetwork_name   = "acme-trust-australia-southeast1"
      create_network    = false  # brownfield!
  }
}

subnetwork_keys_for_firewalls = [
    "acme-untrust-australia-southeast1",
    "acme-mgmt-australia-southeast1",
    "acme-trust-australia-southeast1",
]

subnetwork_key_for_inbound_addresses = "acme-untrust-australia-southeast1"

# main.tf
module vpc {
  networks = var.map
}

resource google_compute_address this {
  subnetwork = module.vpc.subnetworks[var.subnetwork_key_for_inbound_addresses].name
}
```

### Map, Keys Are Just Symbols

```terraform
# us-central1.tfvars
map = {
  "untrust" = {
      network_name    = "acme-untrust"
      subnetwork_name = "acme-untrust-us-central1"
  }
  "mgmt" = {
      network_name    = "acme-mgmt"
      subnetwork_name = "acme-mgmt-us-central1"
  }
  "panorama" = {
      network_name    = "acme-panorama"
      subnetwork_name = "acme-panorama-us-central1"
  }
  "trust" = {
      network_name      = "acme-trust"
      subnetwork_name   = "acme-trust-us-central1"
      create_network    = false  # brownfield!
      create_subnetwork = false  # brownfield!
  }
}

# australia-southeast1.tfvars
map = {
  "untrust" = {
      network_name    = "acme-untrust"
      subnetwork_name = "acme-untrust-australia-southeast1"
      create_network  = false
  }
  "mgmt" = {
      network_name    = "acme-mgmt"
      subnetwork_name = "acme-mgmt-australia-southeast1"
      create_network  = false
  }
  "panorama" = {
      network_name    = "acme-panorama"
      subnetwork_name = "acme-panorama-australia-southeast1"
      create_network  = false
  }
  "trust" = {
      network_name      = "acme-trust"
      subnetwork_name   = "acme-trust-australia-southeast1"
      create_network    = false
  }
}

# common.tfvars
subnetwork_keys_for_firewalls = [
    "untrust",
    "mgmt",
    "trust",
]

# main.tf
module vpc {
  networks = var.map
}

resource google_compute_address this {
  subnetwork = module.vpc.subnetworks["untrust"].name
}
```

### Objects

```terraform
# common.tfvars
untrust_network_name = 
mgmt_network_name = 
panorama_network_name = 
trust_network_name = 

# us-central1.tfvars
untrust_subnetwork_name  = "acme-untrust-us-central1"
mgmt_subnetwork_name     = "acme-mgmt-us-central1"
panorama_subnetwork_name = "acme-panorama-us-central1"
trust_subnetwork_name    = "acme-trust-us-central1"

# australia-southeast1.tfvars
untrust_subnetwork_name  = "acme-untrust-australia-southeast1"
mgmt_subnetwork_name     = "acme-mgmt-australia-southeast1"
panorama_subnetwork_name = "acme-panorama-australia-southeast1"
trust_subnetwork_name    = "acme-trust-australia-southeast1"

# global.tf
module vpc_trust {
  network    = var.trust_network_name
}

module vpc_mgmt {
  network    = var.mgmt_network_name
}

module vpc_untrust {
  network    = var.untrust_network_name
}

# regional.tf
module subnet_trust {
  network    = remote.state.network.name
  subnetwork = var.trust_subnetwork_name
}

module subnet_mgmt {
  network    = remote.state.network.name
  subnetwork = var.mgmt_subnetwork_name
}

module subnet_untrust {
  network    = remote.state.network.name
  subnetwork = var.untrust_subnetwork_name
}

resource google_compute_address this {
  subnetwork = module.subnet_untrust.name
}
```
