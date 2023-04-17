# Palo Alto Networks VM-Series Common Firewall Option

The scope of this code is to deploy an example of the [VM-Series Common Firewall Option](https://www.paloaltonetworks.com/apps/pan/public/downloadResource?pagePath=/content/pan/en_US/resources/guides/gcp-architecture-guide#Design%20Model) architecture within a GCP project.

## Topology

With default variable values the topology consists of :
 - 5 VPC networks :
   - Management VPC
   - Untrust (outside) VPC
   - Trust (inside/security) VPC
   - Spoke-1 VPC
   - Spoke-2 VPC
 - 2 VM-Series firewalls
 - 2 Linux Ubuntu VMs (inside Spoke VPCs - for testing purposes)
 - one internal network loadbalancer (for outbound/east-west traffic)
 - one external regional network loadbalancer (for inbound traffic)

![panorama-topology](https://user-images.githubusercontent.com/43091730/230029801-3acea62e-aa3d-46f3-b638-6b09bf5ef35e.png)

## Prerequisites

1. Prepare [Panorama license](https://support.paloaltonetworks.com/)

2. Configure the terraform [google provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#authentication-configuration)

## Build

1. Access Google Cloud Shell or any other environment which has access to your GCP project

2. Clone the repository:

```
git clone https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules
cd terraform-google-vmseries-modules/examples/panorama
```

3. Fill out any modifications to `example.tfvars` file - at least `project`, `ssh_keys` and `allowed_sources` should be modified for successful deployment and access to the instance.

4. Apply the terraform code:

```
terraform init
terraform apply -var-file=example.tfvars
```

4. Check the output plan and confirm the apply.

5. Check the successful application and outputs of the resulting infrastructure:

```
Apply complete! Resources: 8 added, 0 changed, 0 destroyed. (Number of resources can vary based on how many instances you push through tfvars)

Outputs:

panorama_private_ip = {
  "panorama-01" = "172.21.21.2"
}
panorama_public_ip = {
  "panorama-01" = "x.x.x.x"
}
```


## Post build

Connect to the panorama instance(s) via SSH using your associated private key and set a password:

```
ssh admin@x.x.x.x -i /PATH/TO/YOUR/KEY/id_rsa
Welcome admin.
admin@Panorama> configure
Entering configuration mode
[edit]                                                                                                                                                                                  
admin@Panorama# set mgt-config users admin password
Enter password   : 
Confirm password : 

[edit]                                                                                                                                                                                  
admin@Panorama# commit
Configuration committed successfully
```

## Check access via web UI

Use a web browser to access `https://x.x.x.x` and login with admin and your previously configured password.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0, < 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bootstrap"></a> [bootstrap](#module\_bootstrap) | ../../modules/bootstrap | n/a |
| <a name="module_iam_service_account"></a> [iam\_service\_account](#module\_iam\_service\_account) | ../../modules/iam_service_account | n/a |
| <a name="module_lb_external"></a> [lb\_external](#module\_lb\_external) | ../../modules/lb_external | n/a |
| <a name="module_lb_internal"></a> [lb\_internal](#module\_lb\_internal) | ../../modules/lb_internal | n/a |
| <a name="module_vmseries"></a> [vmseries](#module\_vmseries) | ../../modules/vmseries | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../../modules/vpc | n/a |
| <a name="module_vpc_peering"></a> [vpc\_peering](#module\_vpc\_peering) | ../../modules/vpc-peering | n/a |

## Resources

| Name | Type |
|------|------|
| [google_compute_instance.linux_vm](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_route.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_route) | resource |
| [local_file.bootstrap_xml](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.init_cfg](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [google_compute_image.my_image](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bootstrap_buckets"></a> [bootstrap\_buckets](#input\_bootstrap\_buckets) | A map containing each bootstrap bucket setting.<br><br>Example of variable deployment:<pre>bootstrap_buckets = {<br>  "vmseries-bootstrap-bucket-01" = {<br>    bucket_name_prefix = "bucket-01-"<br>    service_account    = "sa-vmseries-01"<br>    files = {<br>      "bootstrap_files/init-cfg.txt" = "config/init-cfg.txt"<br>      "bootstrap_files/authcodes"    = "license/authcodes"<br>    }<br>  }<br>}</pre>For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/bootstrap#Inputs)<br><br>Multiple keys can be added and will be deployed by the code | `map(any)` | `{}` | no |
| <a name="input_lbs_external"></a> [lbs\_external](#input\_lbs\_external) | A map containing each external loadbalancer setting.<br><br>  Example of variable deployment :<pre>lbs_external = {<br>  "external-lb" = {<br>    name      = "external-lb"<br>    instances = ["fw-vmseries-01", "fw-vmseries-02"]<br>    rules = {<br>      "http" = {<br>        port_range  = "80"<br>        ip_protocol = "TCP"<br>        ip_address  = ""<br>      },<br>      "https" = {<br>        port_range  = "443"<br>        ip_protocol = "TCP"<br>        ip_address  = ""<br>      },<br>      "icmp" = {<br>        port_range  = null<br>        ip_protocol = "ICMP" <br>        ip_address  = ""<br>      }<br>    }<br>    http_health_check_port         = "80"<br>    http_health_check_request_path = "/"<br>  }<br>}</pre>For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/lb_external#inputs)<br><br>  Multiple keys can be added and will be deployed by the code | `map(any)` | `{}` | no |
| <a name="input_lbs_global_http"></a> [lbs\_global\_http](#input\_lbs\_global\_http) | A map containing each Global HTTP setting | `map(any)` | `{}` | no |
| <a name="input_lbs_internal"></a> [lbs\_internal](#input\_lbs\_internal) | A map containing each internal loadbalancer setting.<br><br>Example of variable deployment :<pre>lbs_internal = {<br>  "trust-lb" = {<br>    name              = "trust-lb"<br>    health_check_port = "22"<br>    backends          = ["fw-vmseries-01", "fw-vmseries-02"]<br>    ip_address        = "10.10.12.5"<br>    subnetwork        = "fw-trust-sub"<br>    network           = "fw-trust-vpc"<br>  }<br>}</pre>For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/lb_internal#inputs)<br><br>Multiple keys can be added and will be deployed by the code | `map(any)` | `{}` | no |
| <a name="input_linux_vms"></a> [linux\_vms](#input\_linux\_vms) | A map containing each Linux VM configuration that will be placed in SPOKE VPCs for testing purposes. | `map(any)` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | Location in which the GCS Bucket will be deployed. Available locations can be found under https://cloud.google.com/storage/docs/locations. | `string` | `"us"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A string to prefix resource namings | `string` | `"example-"` | no |
| <a name="input_networks"></a> [networks](#input\_networks) | A map containing each network setting.<br><br>Example of variable deployment :<pre>vpcs = {<br>  "panorama-vpc" = {<br>    vpc_name          = "panorama-vpc"<br>    subnet_name       = "example-panorama-subnet"<br>    cidr              = "172.21.21.0/24"<br>    allowed_sources   = ["1.1.1.1/32" , "2.2.2.2/32"]<br>    create_network    = true<br>    create_subnetwork = true<br>  }<br>}</pre>For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/vpc#input_networks)<br><br>Multiple keys can be added and will be deployed by the code | `any` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | The project name to deploy the infrastructure in to. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | The region into which to deploy the infrastructure in to | `string` | `"us-central1"` | no |
| <a name="input_routes"></a> [routes](#input\_routes) | A map containing each route setting. Note that you can only add routes using a next-hop type of internal load-balance rule.<br><br>  Example of variable deployment :<pre>routes = {<br>  "default-route-trust" = {<br>    name = "fw-default-trust"<br>    destination_range = "0.0.0.0/0"<br>    network = "fw-trust-vpc"<br>    lb_internal_name = "internal-lb"<br>  }<br>}</pre>Multiple keys can be added and will be deployed by the code | `map(any)` | `{}` | no |
| <a name="input_service_accounts"></a> [service\_accounts](#input\_service\_accounts) | A map containing each service account setting.<br><br>Example of variable deployment :<pre>service_accounts = {<br>  "sa-vmseries-01" = {<br>    service_account_id = "sa-vmseries-01"<br>    display_name       = "VM-Series SA"<br>    roles = [<br>      "roles/compute.networkViewer",<br>      "roles/logging.logWriter",<br>      "roles/monitoring.metricWriter",<br>      "roles/monitoring.viewer",<br>      "roles/viewer"<br>    ]<br>  }<br>}</pre>For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/iam_service_account#Inputs)<br><br>Multiple keys can be added and will be deployed by the code | `map(any)` | `{}` | no |
| <a name="input_vmseries"></a> [vmseries](#input\_vmseries) | A map containing each individual vmseries setting.<br><br>Example of variable deployment :<pre>vmseries = {<br>  "fw-vmseries-01" = {<br>    name             = "fw-vmseries-01"<br>    zone             = "us-east1-b"<br>    machine_type     = "n2-standard-4"<br>    min_cpu_platform = "Intel Cascade Lake"<br>    tags             = ["vmseries"]<br>    service_account  = "sa-vmseries-01"<br>    scopes = [<br>      "https://www.googleapis.com/auth/compute.readonly",<br>      "https://www.googleapis.com/auth/cloud.useraccounts.readonly",<br>      "https://www.googleapis.com/auth/devstorage.read_only",<br>      "https://www.googleapis.com/auth/logging.write",<br>      "https://www.googleapis.com/auth/monitoring.write",<br>    ]<br>    bootstrap-bucket-key = "vmseries-bootstrap-bucket-01"<br>    bootstrap_options = {<br>      panorama-server = "1.1.1.1"<br>    }<br>    named_ports = [<br>      {<br>        name = "http"<br>        port = 80<br>      },<br>      {<br>        name = "https"<br>        port = 443<br>      }<br>    ]<br>    network_interfaces = [<br>      {<br>        subnetwork       = "fw-untrust-sub"<br>        private_ip       = "10.10.11.2"<br>        create_public_ip = true<br>      },<br>      {<br>        subnetwork       = "fw-mgmt-sub"<br>        private_ip       = "10.10.10.2"<br>        create_public_ip = true<br>      },<br>      {<br>        subnetwork = "fw-trust-sub"<br>        private_ip = "10.10.12.2"<br>      }<br>    ]<br>  }<br>}</pre>For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/vmseries#inputs)<br><br>Multiple keys can be added and will be deployed by the code | `any` | n/a | yes |
| <a name="input_vmseries_common"></a> [vmseries\_common](#input\_vmseries\_common) | A map containing common vmseries setting.<br><br>Example of variable deployment :<pre>vmseries_common = {<br>  ssh_keys       = "admin:mykey123"<br>  vmseries_image = "vmseries-flex-byol-1022h2"<br>  bootstrap_options = {<br>    type                = "dhcp-client"<br>    dns-primary         = "8.8.8.8"<br>    dns-secondary       = "8.8.4.4"<br>    mgmt-interface-swap = "enable"<br>  }<br>}</pre>Bootstrap options can be moved between vmseries individual instance variable (`vmseries`) and this common vmserie variable (`vmseries_common`) | `any` | n/a | yes |
| <a name="input_vpc_peerings"></a> [vpc\_peerings](#input\_vpc\_peerings) | A map containing each VPC peering setting.<br><br>Example of variable deployment :<pre>vpc_peerings = {<br>  "trust-to-spoke1" = {<br>    local_network = "fw-trust-vpc"<br>    peer_network  = "spoke1-vpc"<br><br>    local_export_custom_routes                = true<br>    local_import_custom_routes                = true<br>    local_export_subnet_routes_with_public_ip = true<br>    local_import_subnet_routes_with_public_ip = true<br><br>    peer_export_custom_routes                = true<br>    peer_import_custom_routes                = true<br>    peer_export_subnet_routes_with_public_ip = true<br>    peer_import_subnet_routes_with_public_ip = true<br>  }<br>}</pre>For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/vpc-peering#inputs)<br><br>Multiple keys can be added and will be deployed by the code | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lbs_external_ips"></a> [lbs\_external\_ips](#output\_lbs\_external\_ips) | Public IP addresses of external network loadbalancers. |
| <a name="output_lbs_internal_ips"></a> [lbs\_internal\_ips](#output\_lbs\_internal\_ips) | Private IP addresses of internal network loadbalancers. |
| <a name="output_linux_vm_ips"></a> [linux\_vm\_ips](#output\_linux\_vm\_ips) | Private IP addresses of Linux VMs. |
| <a name="output_vmseries_private_ips"></a> [vmseries\_private\_ips](#output\_vmseries\_private\_ips) | Private IP addresses of the vmseries instances. |
| <a name="output_vmseries_public_ips"></a> [vmseries\_public\_ips](#output\_vmseries\_public\_ips) | Public IP addresses of the vmseries instances. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
