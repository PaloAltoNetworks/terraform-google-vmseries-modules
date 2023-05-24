# Reference Architecture with Terraform: VM-Series in GCP, Dedicated-Inbound Deployment Option

Palo Alto Networks produces several [validated reference architecture design and deployment documentation guides](https://www.paloaltonetworks.com/resources/reference-architectures), which describe well-architected and tested deployments. When deploying VM-Series in a public cloud, the reference architectures guide users toward the best security outcomes, whilst reducing rollout time and avoiding common integration efforts.
The Terraform code presented here will deploy Palo Alto Networks VM-Series firewalls in GCP based on a centralized design with dedicated-inbound VM-Series; for a discussion of other options, please see the design guide from [the reference architecture guides](https://www.paloaltonetworks.com/resources/reference-architectures).

## Reference Architecture Design

![simple](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/assets/6574404/942d7e0a-eafb-42fb-ba53-6fefedb4b69d)

This code implements:
- a _centralized design_, a hub-and-spoke topology with a shared VPC containing VM-Series to inspect all inbound, outbound, east-west, and enterprise traffic
- the _dedicated inbound option_, which separates inbound traffic flows onto a separate set of VM-Series

## Detailed Architecture and Design

### Centralized Design

This design uses a VPC Peering. Application functions are distributed across multiple projects that are connected in a logical hub-and-spoke topology. A security project acts as the hub, providing centralized connectivity and control for multiple application projects. You deploy all VM-Series firewalls within the security project. The spoke projects contain the workloads and necessary services to support the application deployment.
This design model integrates multiple methods to interconnect and control your application project VPC networks with resources in the security project. VPC Peering enables the private VPC network in the security project to peer with, and share routing information to, each application project VPC network. Using Shared VPC, the security project administrators create and share VPC network resources from within the security project to the application projects. The application project administrators can select the network resources and deploy the application workloads.

### Dedicated Inbound Option

The dedicated inbound option separates traffic flows across two separate sets of VM-Series firewalls. One set of VM-Series firewalls is dedicated to inbound traffic flows, allowing for greater flexibility and scaling of inbound traffic loads. The second set of VM-Series firewalls services all outbound, east-west, and enterprise network traffic flows. This deployment choice offers increased scale and operational resiliency and reduces the chances of high bandwidth use from the inbound traffic flows affecting other traffic flows within the deployment.

![gcp-dedicatedinbound](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/assets/6574404/730530bf-5da6-4943-b686-cbe8fb249b7e)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.3, < 2.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 3.48 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 3.48 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_extlb"></a> [extlb](#module\_extlb) | ../../modules/lb_external/ | n/a |
| <a name="module_glb"></a> [glb](#module\_glb) | ../../modules/lb_http_ext_global | n/a |
| <a name="module_ilb"></a> [ilb](#module\_ilb) | ../../modules/lb_internal | n/a |
| <a name="module_vmseries"></a> [vmseries](#module\_vmseries) | ../../modules/vmseries/ | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../../modules/vpc/ | n/a |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.builtin_healthchecks](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.extlb](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.ssh](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [null_resource.delay_actual_use](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.verify_with_curl](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [google_compute_zones.available](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_request_headers"></a> [custom\_request\_headers](#input\_custom\_request\_headers) | n/a | `list` | `[]` | no |
| <a name="input_mgmt_sources"></a> [mgmt\_sources](#input\_mgmt\_sources) | n/a | `list` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | n/a | `string` | `"example-"` | no |
| <a name="input_project"></a> [project](#input\_project) | n/a | `any` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `any` | n/a | yes |
| <a name="input_ssh_keys"></a> [ssh\_keys](#input\_ssh\_keys) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_global_url"></a> [global\_url](#output\_global\_url) | n/a |
| <a name="output_internal_url"></a> [internal\_url](#output\_internal\_url) | n/a |
| <a name="output_public_ips"></a> [public\_ips](#output\_public\_ips) | n/a |
| <a name="output_regional_url"></a> [regional\_url](#output\_regional\_url) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
