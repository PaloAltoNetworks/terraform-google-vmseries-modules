# VPC Networks Module for GCP

This module is not strictly required for constructing inputs to be passed to other modules (including vmseries or autoscale modules).
Any existing networks/subnetworks can work equally well, independent on how they were created.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

The following requirements are needed by this module:

- terraform (>= 0.12, < 0.13)

- google (~> 3.33)

## Required Inputs

The following input variables are required:

### networks

Description: Map of networks, a minimal example:

```
{
  "my-vpc" = {
    name            = "my-vpc"
    subnetwork_name = "my-subnet"
    ip_cidr_range   = "192.168.1.0/24"
  }
}
```

An advanced example:

```
{
  "my-vpc" = {
    name            = "my-vpc"
    subnetwork_name = "my-subnet"
    ip_cidr_range   = "192.168.1.0/24"
    allowed_sources = ["209.85.152.0/22"]
    log_metadata    = "INCLUDE_ALL_METADATA"
  }
}
```

Full example:

```
{
  "my-vpc" = {
    name             = "my-vpc"
    subnetwork_name  = "my-subnet"
    ip_cidr_range    = "192.168.1.0/24"
    allowed_sources  = ["10.0.0.0/8", "98.98.98.0/28"]
    allowed_protocol = "UDP"
    allowed_ports    = ["53", "123-125"]
    log_metadata     = "EXCLUDE_ALL_METADATA"

    delete_default_routes_on_create = true
  }
  "imported-from-hostproject" = {
    name              = "existing-core-vpc"
    subnetwork_name   = "existing-subnet"
    create_network    = false
    create_subnetwork = false
    host_project_id   = "my-core-project-id"
  }
}
```

Type: `any`

## Optional Inputs

The following input variables are optional (have default values):

### allowed\_ports

Description: A list of ports to pass for the `networks` entries that do not have their own `allowed_ports` attribute. For example ["22", "443"]. Can also include ranges, for example ["80", "8080-8999"]. Empty list means to allow all.

Type: `list(string)`

Default: `[]`

### allowed\_protocol

Description: A protocol (TCP or UDP) to pass for the `networks` entries that do not have their own `allowed_protocol` attribute.

Type: `string`

Default: `"all"`

### region

Description: GCP region for all the created subnetworks and for all the imported subnetworks. Set to null to use a default provider's region.  
To add subnetworks with another region use a separate instance of this module (and specify `create_network=false` to avoid creating a duplicate network).

Type: `string`

Default: `null`

## Outputs

The following outputs are exported:

### networks

Description: n/a

### subnetworks

Description: n/a

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
