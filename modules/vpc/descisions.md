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

## Handle Pre-existing VPC Networks

How to handle customer-provided (also known as *brownfield*) networks and subnetworks.

Decision is to use: ...TODO, fill before merge...

The test-cases, starting from most crucial ones:   FIXME Errors are for merge(x, data.x):

- possible without a total destroy: repeat `terraform apply --refresh`

OK, even the `tf12 refresh`.

- possible without a total destroy: add a subnetwork to a brownfield network (a pre-existing network)

Needs workaround.

- possible without a total destroy: add a brownfield subnetwork (a pre-existing subnetwork)

Good.

- possible without a total destroy: delete a brownfield subnetwork (a pre-existing subnetwork)

Good.

- possible without a total destroy: add a greenfield network with a subnetwork

Needs workaround.

- possible without a total destroy: add another subnetwork to a greenfield network from a previous run

Error: Duplicate object key

  on ../../modules/vpc/main.tf line 3, in locals:
   3:   networks = { for v in var.networks : v.name => v } // tested on tf-0.12, when list elements shift indexes, this map prevents destroy
    |----------------
    | v.name is "my-example3-trust"

Two different items produced the key "my-example3-trust" in this 'for'
expression. If duplicates are expected, use the ellipsis (...) after the value
expression to enable grouping by key.

But the grouping leads to super ugly code, you'd need to merge(each.value[*])

- possible without a total destroy: add a raw greenfield network created by calling terrform-google-modules/network v2.6.0

Needs workaround.

- possible without a total destroy: rename an unused network with its subnetwork

Needs workaround.

- possible without a total destroy: delete an unused network with its subnetwork

OK? Needs a different workaround?

- execute `terraform plan` on tf-0.12

Needs workaround (`terraform plan --target ...` is supported).

- execute `terraform plan` on tf-0.13

Error: Required attribute is not set

  on ../../modules/vpc/main.tf line 62, in resource "google_compute_subnetwork" "this":
  62:   network       = merge(google_compute_network.this, data.google_compute_network.this)[each.value.name].self_link

- destroy an empty state on tf-0.12 (nice to have)

OK, except when trying to pass `module.google_vpc.network_name` (or any other module output), as somehow it invalidates the merge() and propagates as "Error: Invalid for_each argument".

- destroy an empty state on tf-0.13

OK.

- outputs can be used for `for_each`

Needs workaround:

```
tf12 apply --compact-warnings --target module.vpc.google_compute_network.this
tf12 apply --compact-warnings --target module.vpc.google_compute_subnetwork.this
```

When renaming a subnetwork or a network, the workaround is to delete it and then re-add it.

- outputs can be used for `data any any { name = our.output }`

Needs the same workaround as `for_each` test-case.

Possibilities, subjectively worst to best:

### Data Passthrough Method

```
```

On tf-0.12.29 it can handle a repeated `terraform apply` only with `--refresh=false`. Executing `terraform refresh` totally taints the tfstate.
This quite unsafe for out-of-terraform attribute changes, such as drifting away from OPPORTUNISTIC autoscaler strategy.

A partial refresh descends to all the dependencies, so this is not an effective workaround:

```
terraform refresh --target module.anything_except_vpc --target module.another_except_vpc  # will refresh vpc anyway
```

On tf-0.13 there is no such problem.

Example:

```txt
$ terraform apply

  # module.vpc.data.google_compute_network.this["my-vpc"] will be read during apply
  # (config refers to values not yet known)
 <= data "google_compute_network" "this"  {
      + description            = (known after apply)
      + gateway_ipv4           = (known after apply)
      + id                     = (known after apply)
      + name                   = "my-vpc"
      + self_link              = (known after apply)
      + subnetworks_self_links = (known after apply)
    }

  # module.vpc.google_compute_subnetwork.this["my-subnet"] must be replaced
-/+ resource "google_compute_subnetwork" "this" {
      ...
      ~ network                  = "https://www.googleapis.com/compute/v1/projects/gcp-gcs-pso/global/networks/my-vpc" -> (known after apply) # forces replacement
    }
  # module.vmseries.google_compute_instance.this["my-vm02"] must be replaced
-/+ resource "google_compute_instance" "this" {
      ...
      ~ subnetwork         = "https://www.googleapis.com/compute/v1/projects/gcp-gcs-pso/regions/europe-west4/subnetworks/my-subnet" -> (known after apply) # forces replacement
    }
...
```

A workaround:

```txt
$ terraform apply --refresh=false
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```

### Data Merge Method

Drawback: requires documenting a workaround for tf-0.12 (not needed for tf-0.13).

### Alt Module Method
