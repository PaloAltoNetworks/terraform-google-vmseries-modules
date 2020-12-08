# VPC Networks Module for GCP

This module is not strictly required for constructing inputs to be passed to other modules (including vmseries or autoscale modules).
Any existing networks/subnetworks can work equally well, independent on how they were created.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12, < 0.13 |
| google | ~> 3.33 |

## Providers

| Name | Version |
|------|---------|
| google | ~> 3.33 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allowed\_ports | A list of ports to pass for the `networks` entries that do not have their own `allowed_ports` attribute. For example ["22", "443"]. Can also include ranges, for example ["80", "8080-8999"]. Empty list means to allow all. | `list(string)` | `[]` | no |
| allowed\_protocol | A protocol (TCP or UDP) to pass for the `networks` entries that do not have their own `allowed_protocol` attribute. | `string` | `"all"` | no |
| networks | Map of networks, a minimal example:<pre>{<br>  "my-vpc" = {<br>    name            = "my-vpc"<br>    subnetwork_name = "my-subnet"<br>    ip_cidr_range   = "192.168.1.0/24"<br>  }<br>}</pre>An advanced example:<pre>{<br>  "my-vpc" = {<br>    name            = "my-vpc"<br>    subnetwork_name = "my-subnet"<br>    ip_cidr_range   = "192.168.1.0/24"<br>    allowed_sources = ["209.85.152.0/22"]<br>    log_metadata    = "INCLUDE_ALL_METADATA"<br>  }<br>}</pre>Full example:<pre>{<br>  "my-vpc" = {<br>    name             = "my-vpc"<br>    subnetwork_name  = "my-subnet"<br>    ip_cidr_range    = "192.168.1.0/24"<br>    allowed_sources  = ["10.0.0.0/8", "98.98.98.0/28"]<br>    allowed_protocol = "UDP"<br>    allowed_ports    = ["53", "123-125"]<br>    log_metadata     = "EXCLUDE_ALL_METADATA"<br><br>    delete_default_routes_on_create = true<br>  }<br>  "imported-from-hostproject" = {<br>    name              = "existing-core-vpc"<br>    subnetwork_name   = "existing-subnet"<br>    create_network    = false<br>    create_subnetwork = false<br>    host_project_id   = "my-core-project-id"<br>  }<br>}</pre> | `any` | n/a | yes |
| region | GCP region for all the created subnetworks and for all the imported subnetworks. Set to null to use a default provider's region.<br><br>To add subnetworks with another region use a separate instance of this module (and specify `create_network=false` to avoid creating a duplicate network). | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| networks | n/a |
| subnetworks | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
