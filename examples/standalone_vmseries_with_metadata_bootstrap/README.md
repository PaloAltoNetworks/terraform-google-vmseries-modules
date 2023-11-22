---
show_in_hub: false
---
# Palo Alto Networks VM-Series NGFW Module Example

A Terraform module example for deploying a VM-Series NGFW in GCP using the [metadata](https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/bootstrap-the-vm-series-firewall/choose-a-bootstrap-method#idf6412176-e973-488e-9d7a-c568fe1e33a9) bootstrap method.

This example can be used to familarize oneself with both the VM-Series NGFW and Terraform - it creates a single instance of virtualized firewall in a Security VPC with a management-only interface and lacks any traffic inspection.

## Reference
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3, < 2.0 |

### Providers

No providers.

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vmseries"></a> [vmseries](#module\_vmseries) | ../../modules/vmseries | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../../modules/vpc | n/a |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A string to prefix resource namings | `string` | `""` | no |
| <a name="input_networks"></a> [networks](#input\_networks) | A map containing each network setting.<br><br>Example of variable deployment :<pre>networks = {<br>  "vmseries-vpc" = {<br>    vpc_name                        = "firewall-vpc"<br>    create_network                  = true<br>    delete_default_routes_on_create = "false"<br>    mtu                             = "1460"<br>    routing_mode                    = "REGIONAL"<br>    subnetworks = {<br>      "vmseries-sub" = {<br>        name              = "vmseries-subnet"<br>        create_subnetwork = true<br>        ip_cidr_range     = "172.21.21.0/24"<br>        region            = "us-central1"<br>      }<br>    }<br>    firewall_rules = {<br>      "allow-vmseries-ingress" = {<br>        name             = "vmseries-mgmt"<br>        source_ranges    = ["1.1.1.1/32", "2.2.2.2/32"]<br>        priority         = "1000"<br>        allowed_protocol = "all"<br>        allowed_ports    = []<br>      }<br>    }<br>  }</pre>For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/vpc#input_networks)<br><br>Multiple keys can be added and will be deployed by the code | `any` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | The project name to deploy the infrastructure in to. | `string` | `null` | no |
| <a name="input_vmseries"></a> [vmseries](#input\_vmseries) | A map containing each individual vmseries setting.<br><br>Example of variable deployment :<pre>vmseries = {<br>    "fw-vmseries-01" = {<br>      name             = "fw-vmseries-01"<br>      zone             = "us-central1-b"<br>      vmseries_image   = "vmseries-flex-byol-1022h2"<br>      ssh_keys         = "admin:<YOUR_SSH_KEY>"<br>      machine_type     = "n2-standard-4"<br>      min_cpu_platform = "Intel Cascade Lake"<br>      tags             = ["vmseries"]<br>      scopes = [<br>        "https://www.googleapis.com/auth/compute.readonly",<br>        "https://www.googleapis.com/auth/cloud.useraccounts.readonly",<br>        "https://www.googleapis.com/auth/devstorage.read_only",<br>        "https://www.googleapis.com/auth/logging.write",<br>        "https://www.googleapis.com/auth/monitoring.write",<br>      ]<br>      bootstrap_options = {<br>        panorama-server = "1.1.1.1" # Modify this value as per deployment requirements<br>        dns-primary     = "8.8.8.8" # Modify this value as per deployment requirements<br>        dns-secondary   = "8.8.4.4" # Modify this value as per deployment requirements<br>      }<br>      named_ports = [<br>        {<br>          name = "http"<br>          port = 80<br>        },<br>        {<br>          name = "https"<br>          port = 443<br>        }<br>      ]<br>      network_interfaces = [<br>        {<br>          vpc_network_key  = "vmseries-vpc"<br>          subnetwork_key   = "fw-mgmt-sub"<br>          private_ip       = "10.10.10.2"<br>          create_public_ip = true<br>        }<br>      ]<br>    }<br>  }</pre>For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/vmseries#inputs)<br><br>The bootstrap\_template\_map contains variables that will be applied to the bootstrap template. Each firewall Day 0 bootstrap will be parametrised based on these inputs.<br>Multiple keys can be added and will be deployed by the code. | `any` | n/a | yes |
| <a name="input_vmseries_common"></a> [vmseries\_common](#input\_vmseries\_common) | A map containing common vmseries setting.<br><br>Example of variable deployment :<pre>vmseries_common = {<br>  ssh_keys            = "admin:AAAABBBB..."<br>  vmseries_image      = "vmseries-flex-byol-1022h2"<br>  machine_type        = "n2-standard-4"<br>  min_cpu_platform    = "Intel Cascade Lake"<br>  service_account_key = "sa-vmseries-01"<br>  bootstrap_options = {<br>    type                = "dhcp-client"<br>    mgmt-interface-swap = "enable"<br>  }<br>}</pre>Bootstrap options can be moved between vmseries individual instance variable (`vmseries`) and this common vmserie variable (`vmseries_common`). | `map` | `{}` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_vmseries_private_ips"></a> [vmseries\_private\_ips](#output\_vmseries\_private\_ips) | Private IP addresses of the vmseries instances. |
| <a name="output_vmseries_public_ips"></a> [vmseries\_public\_ips](#output\_vmseries\_public\_ips) | Public IP addresses of the vmseries instances. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->