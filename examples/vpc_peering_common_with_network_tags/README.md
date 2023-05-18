# Palo Alto Networks VM-Series Common Firewall Option with network tags

The scope of this code is to deploy an example of the [VM-Series Common Firewall Option](https://www.paloaltonetworks.com/apps/pan/public/downloadResource?pagePath=/content/pan/en_US/resources/guides/gcp-architecture-guide#Design%20Model) architecture in two regions and using network tags feature for traffic distribution within a GCP project.

The example makes use of VM-Series full [bootstrap process](https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/bootstrap-the-vm-series-firewall/bootstrap-the-vm-series-firewall-on-google) using XML templates to properly parametrise the initial Day 0 configuration.

## Topology

With default variable values the topology consists of :
 - 4 VPC networks :
   - Management VPC
   - Untrust (outside) VPC
   - Trust (inside/security) VPC
   - Spoke-1 VPC
 - 4 VM-Series firewalls (2 per region)
 - 2 Linux Ubuntu VMs (inside Spoke VPC - for testing purposes)
 - two internal network loadbalancer (for outbound/east-west traffic)
 - two external regional network loadbalancer (for inbound traffic)
 - two static routes with intance tag based on each region

![vpc-peering-network-tags](https://user-images.githubusercontent.com/43091730/234361631-651c0eaa-fb4c-46dd-b654-ddb1c5a600f0.png)

### Traffic flows details

- Spoke Linux VM 1 will have the network tag value of the `var.region-1` variable thus inheriting the default route towards region-1 internal loadbalancer.
- Spoke Linux VM 2 will inherit the network tag value of the `var.region-2` variable thus sending traffic towards region-2 internal laodbalancer.
- In the bootstrap XML file there are two NAT policies configured :
  - One for outside traffic (trust to untrust).
  - One for east-west traffic (trust to trust) - this one is required for symmetric traffic flows for east-west traffic in case there are multiple spoke VPC networks.

## Prerequisites

1. Prepare [VM-Series licenses](https://support.paloaltonetworks.com/)

2. Configure the terraform [google provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#authentication-configuration)

## Build

1. Access Google Cloud Shell or any other environment which has access to your GCP project

2. Clone the repository:

```
git clone https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules
cd terraform-google-vmseries-modules/examples/vpc-peering-common-with-network-tags
```

3. Fill out any modifications to `example.tfvars` file - at least `project`, `ssh_keys` and `allowed_sources` should be modified for successful deployment and access to the instance. There is also a few variables that have some default values but which should also be changed as per deployment requirements :
 - General
   - region_1
   - region_2
 - vmseries
   - bootstrap_options
     - panorama-server
     - dns-primary
     - dns-secondary
  - linux_vms
    - linux_disk_size

4. Apply the terraform code:

```
terraform init
terraform apply -var-file=example.tfvars
```

4. Check the output plan and confirm the apply.

5. Check the successful application and outputs of the resulting infrastructure:

```
Apply complete! Resources: 115 added, 0 changed, 0 destroyed. (Number of resources can vary based on how many instances you push through tfvars)

Outputs:

lbs_external_ips_region_1 = {
  "external-lb" = {
    "all-ports-region-1" = "<EXTERNAL_LB_PUBLIC_IP>"
  }
}
lbs_external_ips_region_2 = {
  "external-lb" = {
    "all-ports-region-2" = "<EXTERNAL_LB_PUBLIC_IP>"
  }
}
lbs_internal_ips_region_1 = {
  "internal-lb" = "10.10.12.5"
}
lbs_internal_ips_region_2 = {
  "internal-lb" = "10.20.12.5"
}
linux_vm_ips_region_1 = {
  "spoke1-vm" = "192.168.1.2"
}
linux_vm_ips_region_2 = {
  "spoke2-vm" = "192.168.2.2"
}
vmseries_private_ips_region_1 = {
  "fw-vmseries-01" = {
    "0" = "10.10.11.2"
    "1" = "10.10.10.2"
    "2" = "10.10.12.2"
  }
  "fw-vmseries-02" = {
    "0" = "10.10.11.3"
    "1" = "10.10.10.3"
    "2" = "10.10.12.3"
  }
}
vmseries_private_ips_region_2 = {
  "fw-vmseries-03" = {
    "0" = "10.20.11.2"
    "1" = "10.20.10.2"
    "2" = "10.20.12.2"
  }
  "fw-vmseries-04" = {
    "0" = "10.20.11.3"
    "1" = "10.20.10.3"
    "2" = "10.20.12.3"
  }
}
vmseries_public_ips_region_1 = {
  "fw-vmseries-01" = {
    "0" = "<UNTRUST_PUBLIC_IP>"
    "1" = "34.23.101.41"
  }
  "fw-vmseries-02" = {
    "0" = "<UNTRUST_PUBLIC_IP>"
    "1" = "<MGMT_PUBLIC_IP>"
  }
}
vmseries_public_ips_region_2 = {
  "fw-vmseries-03" = {
    "0" = "<UNTRUST_PUBLIC_IP>"
    "1" = "<MGMT_PUBLIC_IP>"
  }
  "fw-vmseries-04" = {
    "0" = "<UNTRUST_PUBLIC_IP>"
    "1" = "<MGMT_PUBLIC_IP>"
  }
}
```


## Post build

Connect to the VM-Series instance(s) via SSH using your associated private key and check if the bootstrap process if finished successfuly and then set a password :
  - Please allow for up to 10-15 minutes for the bootstrap process to finish
  - The key output you should check for is "Auto-commit Successful"

```
ssh admin@x.x.x.x -i /PATH/TO/YOUR/KEY/id_rsa
Welcome admin.
admin@PA-VM> show system bootstrap status

Bootstrap Phase               Status         Details
===============               ======         =======
Media Detection               Success        Media detected successfully
Media Sanity Check            Success        Media sanity check successful
Parsing of Initial Config     Successful     
Auto-commit                   Successful

admin@PA-VM> configure
Entering configuration mode
[edit]                                                                                                                                                                                  
admin@PA-VM# set mgt-config users admin password
Enter password   : 
Confirm password : 

[edit]                                                                                                                                                                                  
admin@PA-VM# commit
Configuration committed successfully
```

## Check access via web UI

Use a web browser to access `https://<MGMT_PUBLIC_IP>` and login with admin and your previously configured password.

## Check traffic from spoke VMs

The firewalls are bootstrapped with a generic `allow any` policy just for demo purposes along with an outboud SNAT policy to allow Inernet access from spoke VMs.

SSH to the spoke VMs using GCP IAP and gcloud command and test connectivity :


```
gcloud compute ssh spoke1-vm
No zone specified. Using zone [us-east1-b] for instance: [spoke1-vm].
External IP address was not found; defaulting to using IAP tunneling.
WARNING: 

To increase the performance of the tunnel, consider installing NumPy. For instructions,
please see https://cloud.google.com/iap/docs/using-tcp-forwarding#increasing_the_tcp_upload_bandwidth

<USERNAME>@spoke1-vm:~$ping 8.8.8.8
```

```
gcloud compute ssh spoke2-vm
No zone specified. Using zone [us-west1-b] for instance: [spoke2-vm].
External IP address was not found; defaulting to using IAP tunneling.
WARNING: 

To increase the performance of the tunnel, consider installing NumPy. For instructions,
please see https://cloud.google.com/iap/docs/using-tcp-forwarding#increasing_the_tcp_upload_bandwidth

<USERNAME>@spoke2-vm:~$ping 8.8.8.8
```

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
| <a name="module_lb_external_region_1"></a> [lb\_external\_region\_1](#module\_lb\_external\_region\_1) | ../../modules/lb_external | n/a |
| <a name="module_lb_external_region_2"></a> [lb\_external\_region\_2](#module\_lb\_external\_region\_2) | ../../modules/lb_external | n/a |
| <a name="module_lb_internal_region_1"></a> [lb\_internal\_region\_1](#module\_lb\_internal\_region\_1) | ../../modules/lb_internal | n/a |
| <a name="module_lb_internal_region_2"></a> [lb\_internal\_region\_2](#module\_lb\_internal\_region\_2) | ../../modules/lb_internal | n/a |
| <a name="module_vmseries_region_1"></a> [vmseries\_region\_1](#module\_vmseries\_region\_1) | ../../modules/vmseries | n/a |
| <a name="module_vmseries_region_2"></a> [vmseries\_region\_2](#module\_vmseries\_region\_2) | ../../modules/vmseries | n/a |
| <a name="module_vpc_peering"></a> [vpc\_peering](#module\_vpc\_peering) | ../../modules/vpc-peering | n/a |
| <a name="module_vpc_region_1"></a> [vpc\_region\_1](#module\_vpc\_region\_1) | ../../modules/vpc | n/a |
| <a name="module_vpc_region_2"></a> [vpc\_region\_2](#module\_vpc\_region\_2) | ../../modules/vpc | n/a |

## Resources

| Name | Type |
|------|------|
| [google_compute_instance.linux_vm_region_1](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_instance.linux_vm_region_2](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_route.route_region_1](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_route) | resource |
| [google_compute_route.route_region_2](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_route) | resource |
| [local_file.bootstrap_xml_region_1](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.bootstrap_xml_region_2](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.init_cfg_region_1](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.init_cfg_region_2](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [google_compute_image.my_image](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bootstrap_buckets"></a> [bootstrap\_buckets](#input\_bootstrap\_buckets) | A map containing each bootstrap bucket setting.<br><br>Example of variable deployment:<pre>bootstrap_buckets = {<br>  "vmseries-bootstrap-bucket-01" = {<br>    bucket_name_prefix = "bucket-01-"<br>    service_account    = "sa-vmseries-01"<br>  }<br>}</pre>For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/bootstrap#Inputs)<br><br>Multiple keys can be added and will be deployed by the code. | `map(any)` | `{}` | no |
| <a name="input_lbs_external_region_1"></a> [lbs\_external\_region\_1](#input\_lbs\_external\_region\_1) | A map containing each external loadbalancer setting for region\_1 instances.<br><br>Example of variable deployment :<pre>lbs_external_region_1 = {<br>  external-lb = {<br>    name     = "external-lb"<br>    backends = ["fw-vmseries-01", "fw-vmseries-02"]<br>    rules = {<br>      all-ports-region_1 = {<br>        ip_protocol = "L3_DEFAULT"<br>      }<br>    }<br>    http_health_check_port         = "80"<br>    http_health_check_request_path = "/php/login.php"<br>  }<br>}</pre>For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/lb_external#inputs)<br><br>Multiple keys can be added and will be deployed by the code. | `map(any)` | `{}` | no |
| <a name="input_lbs_external_region_2"></a> [lbs\_external\_region\_2](#input\_lbs\_external\_region\_2) | A map containing each external loadbalancer setting for region\_2 instances.<br><br>Example of variable deployment :<pre>lbs_external_region_2 = {<br>  external-lb = {<br>    name     = "external-lb"<br>    backends = ["fw-vmseries-03", "fw-vmseries-04"]<br>    rules = {<br>      all-ports-region_2 = {<br>        ip_protocol = "L3_DEFAULT"<br>      }<br>    }<br>    http_health_check_port         = "80"<br>    http_health_check_request_path = "/php/login.php"<br>  }<br>}</pre>For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/lb_external#inputs)<br><br>Multiple keys can be added and will be deployed by the code. | `map(any)` | `{}` | no |
| <a name="input_lbs_internal_region_1"></a> [lbs\_internal\_region\_1](#input\_lbs\_internal\_region\_1) | A map containing each internal loadbalancer setting for region\_1 instances.<br><br>Example of variable deployment :<pre>lbs_internal_region_1 = {<br>  internal-lb = {<br>    name              = "internal-lb"<br>    health_check_port = "80"<br>    backends          = ["fw-vmseries-01", "fw-vmseries-02"]<br>    ip_address        = "10.10.12.5"<br>    subnetwork        = "fw-trust-sub"<br>    network           = "fw-trust-vpc"<br>  }<br>}</pre>For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/lb_internal#inputs)<br><br>Multiple keys can be added and will be deployed by the code. | `map(any)` | `{}` | no |
| <a name="input_lbs_internal_region_2"></a> [lbs\_internal\_region\_2](#input\_lbs\_internal\_region\_2) | A map containing each internal loadbalancer setting for region\_2 instances.<br><br>Example of variable deployment :<pre>lbs_internal_region_2 = {<br>  internal-lb = {<br>    name              = "internal-lb"<br>    health_check_port = "80"<br>    backends          = ["fw-vmseries-03", "fw-vmseries-04"]<br>    ip_address        = "10.20.12.5"<br>    subnetwork        = "fw-trust-sub"<br>    network           = "fw-trust-vpc"<br>  }<br>}</pre>For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/lb_internal#inputs)<br><br>Multiple keys can be added and will be deployed by the code. | `map(any)` | `{}` | no |
| <a name="input_linux_vms_region_1"></a> [linux\_vms\_region\_1](#input\_linux\_vms\_region\_1) | A map containing each Linux VM configuration in region\_1 that will be placed in spoke VPC network for testing purposes.<br><br>Example of varaible deployment:<pre>linux_vms_region_1 = {<br>  spoke1-vm = {<br>    linux_machine_type = "n2-standard-4"<br>    zone               = "us-east1-b"<br>    linux_disk_size    = "50"<br>    subnetwork         = "spoke1-sub"<br>    private_ip         = "192.168.1.2"<br>    scopes = [<br>      "https://www.googleapis.com/auth/compute.readonly",<br>      "https://www.googleapis.com/auth/cloud.useraccounts.readonly",<br>      "https://www.googleapis.com/auth/devstorage.read_only",<br>      "https://www.googleapis.com/auth/logging.write",<br>      "https://www.googleapis.com/auth/monitoring.write",<br>    ]<br>    service_account = "sa-linux-01"<br>  }<br>}</pre> | `map(any)` | `{}` | no |
| <a name="input_linux_vms_region_2"></a> [linux\_vms\_region\_2](#input\_linux\_vms\_region\_2) | A map containing each Linux VM configuration in region\_2 that will be placed in spoke VPC network for testing purposes.<br><br>Example of varaible deployment:<pre>linux_vms_region_2 = {<br>  spoke2-vm = {<br>    linux_machine_type = "n2-standard-4"<br>    zone               = "us-west1-b"<br>    linux_disk_size    = "50"<br>    subnetwork         = "spoke1-sub"<br>    private_ip         = "192.168.2.2"<br>    scopes = [<br>      "https://www.googleapis.com/auth/compute.readonly",<br>      "https://www.googleapis.com/auth/cloud.useraccounts.readonly",<br>      "https://www.googleapis.com/auth/devstorage.read_only",<br>      "https://www.googleapis.com/auth/logging.write",<br>      "https://www.googleapis.com/auth/monitoring.write",<br>    ]<br>    service_account = "sa-linux-01"<br>  }<br>}</pre> | `map(any)` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | Location in which the GCS Bucket will be deployed. Available locations can be found under https://cloud.google.com/storage/docs/locations. | `string` | `"us"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A string to prefix resource namings. | `string` | `"example-"` | no |
| <a name="input_networks_region_1"></a> [networks\_region\_1](#input\_networks\_region\_1) | A map containing each network setting for region\_1.<br><br>This map also contains the VPC networks creation for the deployment.<br><br>Example of variable deployment :<pre>networks_region_1 = {<br>  mgmt = {<br>    create_network                  = true<br>    create_subnetwork               = true<br>    name                            = "fw-mgmt-vpc"<br>    subnetwork_name                 = "fw-mgmt-sub"<br>    ip_cidr_range                   = "10.10.10.0/28"<br>    allowed_sources                 = ["1.1.1.1/32"]<br>    delete_default_routes_on_create = false<br>    allowed_protocol                = "all"<br>    allowed_ports                   = []<br>  }<br>}</pre>For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/vpc#input_networks)<br><br>Multiple keys can be added and will be deployed by the code. | `any` | n/a | yes |
| <a name="input_networks_region_2"></a> [networks\_region\_2](#input\_networks\_region\_2) | A map containing each network setting for region\_2.<br><br>In this map - only subnetworks are being  created, while referencing previously created VPC networks.<br><br>Example of variable deployment :<pre>networks_region_2 = {<br>  mgmt = {<br>    create_network    = false<br>    create_subnetwork = true<br>    name              = "fw-mgmt-vpc"<br>    subnetwork_name   = "fw-mgmt-sub"<br>    ip_cidr_range     = "10.20.10.0/28"<br>  }<br>}</pre>For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/vpc#input_networks)<br><br>Multiple keys can be added and will be deployed by the code. | `any` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | The project name to deploy the infrastructure in to. | `string` | `null` | no |
| <a name="input_region_1"></a> [region\_1](#input\_region\_1) | The first region into which to deploy the infrastructure in to. | `string` | `"us-east1"` | no |
| <a name="input_region_2"></a> [region\_2](#input\_region\_2) | The second region into which to deploy the infrastructure in to. | `string` | `"us-west1"` | no |
| <a name="input_routes_region_1"></a> [routes\_region\_1](#input\_routes\_region\_1) | A map containing each route setting for region\_1. Note that you can only add routes using a next-hop type of internal load-balance rule.<br><br>The code automatically binds this route to an instance network tag that has the value of region\_1 variable.<br><br>Example of variable deployment :<pre>routes-region_1 = {<br>  fw-default-trust = {<br>    name              = "fw-default-trust"<br>    destination_range = "0.0.0.0/0"<br>    network           = "spoke1-vpc"<br>    lb_internal_key   = "internal-lb"<br>  }<br>}</pre>Multiple keys can be added and will be deployed by the code. | `map(any)` | `{}` | no |
| <a name="input_routes_region_2"></a> [routes\_region\_2](#input\_routes\_region\_2) | A map containing each route setting for region\_2. Note that you can only add routes using a next-hop type of internal load-balance rule.<br><br>The code automatically binds this route to an instance network tag that has the value of region\_2 variable.<br><br>Example of variable deployment :<pre>routes-region_2 = {<br>  fw-default-trust = {<br>    name              = "fw-default-trust"<br>    destination_range = "0.0.0.0/0"<br>    network           = "spoke1-vpc"<br>    lb_internal_key   = "internal-lb"<br>  }<br>}</pre>Multiple keys can be added and will be deployed by the code. | `map(any)` | `{}` | no |
| <a name="input_service_accounts"></a> [service\_accounts](#input\_service\_accounts) | A map containing each service account setting.<br><br>Example of variable deployment :<pre>service_accounts = {<br>  "sa-vmseries-01" = {<br>    service_account_id = "sa-vmseries-01"<br>    display_name       = "VM-Series SA"<br>    roles = [<br>      "roles/compute.networkViewer",<br>      "roles/logging.logWriter",<br>      "roles/monitoring.metricWriter",<br>      "roles/monitoring.viewer",<br>      "roles/viewer"<br>    ]<br>  }<br>}</pre>For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/iam_service_account#Inputs)<br><br>Multiple keys can be added and will be deployed by the code. | `map(any)` | `{}` | no |
| <a name="input_vmseries_common"></a> [vmseries\_common](#input\_vmseries\_common) | A map containing common vmseries setting.<br><br>Example of variable deployment :<pre>vmseries_common = {<br>  ssh_keys       = "admin:ssh-rsa AAAAB3..."<br>  vmseries_image = "vmseries-flex-byol-1022h2"<br>  bootstrap_options = {<br>    type                = "dhcp-client"<br>    mgmt-interface-swap = "enable"<br>  }<br>}</pre>Bootstrap options can be moved between vmseries individual instance variable (`vmseries`) and this common vmserie variable (`vmseries_common`). | `any` | n/a | yes |
| <a name="input_vmseries_region_1"></a> [vmseries\_region\_1](#input\_vmseries\_region\_1) | A map containing each individual vmseries setting for region\_1 instances.<br><br>Example of variable deployment :<pre>vmseries_region_1 = {<br>  fw-vmseries-01 = {<br>    name = "fw-vmseries-01"<br>    zone = "us-east1-b"<br>    tags = ["vmseries"]<br>    scopes = [<br>      "https://www.googleapis.com/auth/compute.readonly",<br>      "https://www.googleapis.com/auth/cloud.useraccounts.readonly",<br>      "https://www.googleapis.com/auth/devstorage.read_only",<br>      "https://www.googleapis.com/auth/logging.write",<br>      "https://www.googleapis.com/auth/monitoring.write",<br>    ]<br>    bootstrap-bucket-key = "vmseries-bootstrap-bucket-01"<br>    bootstrap_options = {<br>      panorama-server = "1.1.1.1"<br>      dns-primary     = "8.8.8.8"<br>      dns-secondary   = "8.8.4.4"<br>    }<br>    bootstrap_template_map = {<br>      trust_gcp_router_ip   = "10.10.12.1"<br>      untrust_gcp_router_ip = "10.10.11.1"<br>      private_network_cidr  = "192.168.0.0/16"<br>      untrust_loopback_ip   = "1.1.1.1/32" # This is placeholder IP - you must replace it on the vmseries config with the LB public IP address (region_1) after the infrastructure is deployed<br>      trust_loopback_ip     = "10.10.12.5/32"<br>    }<br>    named_ports = [<br>      {<br>        name = "http"<br>        port = 80<br>      },<br>      {<br>        name = "https"<br>        port = 443<br>      }<br>    ]<br>    network_interfaces = [<br>      {<br>        subnetwork       = "fw-untrust-sub"<br>        private_ip       = "10.10.11.2"<br>        create_public_ip = true<br>      },<br>      {<br>        subnetwork       = "fw-mgmt-sub"<br>        private_ip       = "10.10.10.2"<br>        create_public_ip = true<br>      },<br>      {<br>        subnetwork = "fw-trust-sub"<br>        private_ip = "10.10.12.2"<br>      }<br>    ]<br>  },<br>  fw-vmseries-02 = {<br>    name = "fw-vmseries-02"<br>    zone = "us-east1-c"<br>    tags = ["vmseries"]<br>    scopes = [<br>      "https://www.googleapis.com/auth/compute.readonly",<br>      "https://www.googleapis.com/auth/cloud.useraccounts.readonly",<br>      "https://www.googleapis.com/auth/devstorage.read_only",<br>      "https://www.googleapis.com/auth/logging.write",<br>      "https://www.googleapis.com/auth/monitoring.write",<br>    ]<br>    bootstrap-bucket-key = "vmseries-bootstrap-bucket-01"<br>    bootstrap_options = {<br>      panorama-server = "1.1.1.1"<br>      dns-primary     = "8.8.8.8"<br>      dns-secondary   = "8.8.4.4"<br>    }<br>    bootstrap_template_map = {<br>      trust_gcp_router_ip   = "10.10.12.1"<br>      untrust_gcp_router_ip = "10.10.11.1"<br>      private_network_cidr  = "192.168.0.0/16"<br>      untrust_loopback_ip   = "1.1.1.1/32" # This is placeholder IP - you must replace it on the vmseries config with the LB public IP address (region_1) after the infrastructure is deployed<br>      trust_loopback_ip     = "10.10.12.5/32"<br>    }<br>    named_ports = [<br>      {<br>        name = "http"<br>        port = 80<br>      },<br>      {<br>        name = "https"<br>        port = 443<br>      }<br>    ]<br>    network_interfaces = [<br>      {<br>        subnetwork       = "fw-untrust-sub"<br>        private_ip       = "10.10.11.3"<br>        create_public_ip = true<br>      },<br>      {<br>        subnetwork       = "fw-mgmt-sub"<br>        private_ip       = "10.10.10.3"<br>        create_public_ip = true<br>      },<br>      {<br>        subnetwork = "fw-trust-sub"<br>        private_ip = "10.10.12.3"<br>      }<br>    ]<br>  }<br>}</pre>For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/vmseries#inputs)<br><br>The bootstrap\_template\_map contains variables that will be applied to the bootstrap template. Each firewall Day 0 bootstrap will be parametrised based on these inputs.<br>Multiple keys can be added and will be deployed by the code. | `any` | n/a | yes |
| <a name="input_vmseries_region_2"></a> [vmseries\_region\_2](#input\_vmseries\_region\_2) | A map containing each individual vmseries setting for region\_2 instances.<br><br>Example of variable deployment :<pre>vmseries_region_2 = {<br>  fw-vmseries-03 = {<br>    name = "fw-vmseries-03"<br>    zone = "us-west1-b"<br>    tags = ["vmseries"]<br>    scopes = [<br>      "https://www.googleapis.com/auth/compute.readonly",<br>      "https://www.googleapis.com/auth/cloud.useraccounts.readonly",<br>      "https://www.googleapis.com/auth/devstorage.read_only",<br>      "https://www.googleapis.com/auth/logging.write",<br>      "https://www.googleapis.com/auth/monitoring.write",<br>    ]<br>    bootstrap-bucket-key = "vmseries-bootstrap-bucket-01"<br>    bootstrap_options = {<br>      panorama-server = "1.1.1.1"<br>      dns-primary     = "8.8.8.8"<br>      dns-secondary   = "8.8.4.4"<br>    }<br>    bootstrap_template_map = {<br>      trust_gcp_router_ip   = "10.20.12.1"<br>      untrust_gcp_router_ip = "10.20.11.1"<br>      private_network_cidr  = "192.168.0.0/16"<br>      untrust_loopback_ip   = "2.2.2.2/32" # This is placeholder IP - you must replace it on the vmseries config with the LB public IP address (region_2) after the infrastructure is deployed<br>      trust_loopback_ip     = "10.20.12.5/32"<br>    }<br>    named_ports = [<br>      {<br>        name = "http"<br>        port = 80<br>      },<br>      {<br>        name = "https"<br>        port = 443<br>      }<br>    ]<br>    network_interfaces = [<br>      {<br>        subnetwork       = "fw-untrust-sub"<br>        private_ip       = "10.20.11.2"<br>        create_public_ip = true<br>      },<br>      {<br>        subnetwork       = "fw-mgmt-sub"<br>        private_ip       = "10.20.10.2"<br>        create_public_ip = true<br>      },<br>      {<br>        subnetwork = "fw-trust-sub"<br>        private_ip = "10.20.12.2"<br>      }<br>    ]<br>  },<br>  fw-vmseries-04 = {<br>    name = "fw-vmseries-04"<br>    zone = "us-west1-c"<br>    tags = ["vmseries"]<br>    scopes = [<br>      "https://www.googleapis.com/auth/compute.readonly",<br>      "https://www.googleapis.com/auth/cloud.useraccounts.readonly",<br>      "https://www.googleapis.com/auth/devstorage.read_only",<br>      "https://www.googleapis.com/auth/logging.write",<br>      "https://www.googleapis.com/auth/monitoring.write",<br>    ]<br>    bootstrap-bucket-key = "vmseries-bootstrap-bucket-01"<br>    bootstrap_options = {<br>      panorama-server = "1.1.1.1"<br>      dns-primary     = "8.8.8.8"<br>      dns-secondary   = "8.8.4.4"<br>    }<br>    bootstrap_template_map = {<br>      trust_gcp_router_ip   = "10.20.12.1"<br>      untrust_gcp_router_ip = "10.20.11.1"<br>      private_network_cidr  = "192.168.0.0/16"<br>      untrust_loopback_ip   = "2.2.2.2/32" # This is placeholder IP - you must replace it on the vmseries config with the LB public IP address (region_2) after the infrastructure is deployed<br>      trust_loopback_ip     = "10.20.12.5/32"<br>    }<br>    named_ports = [<br>      {<br>        name = "http"<br>        port = 80<br>      },<br>      {<br>        name = "https"<br>        port = 443<br>      }<br>    ]<br>    network_interfaces = [<br>      {<br>        subnetwork       = "fw-untrust-sub"<br>        private_ip       = "10.20.11.3"<br>        create_public_ip = true<br>      },<br>      {<br>        subnetwork       = "fw-mgmt-sub"<br>        private_ip       = "10.20.10.3"<br>        create_public_ip = true<br>      },<br>      {<br>        subnetwork = "fw-trust-sub"<br>        private_ip = "10.20.12.3"<br>      }<br>    ]<br>  }<br>}</pre>For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/vmseries#inputs)<br><br>The bootstrap\_template\_map contains variables that will be applied to the bootstrap template. Each firewall Day 0 bootstrap will be parametrised based on these inputs.<br>Multiple keys can be added and will be deployed by the code. | `any` | n/a | yes |
| <a name="input_vpc_peerings"></a> [vpc\_peerings](#input\_vpc\_peerings) | A map containing each VPC peering setting.<br><br>This is done only once since it's being called at the network level and not at the subnetwork which is dependent on the region.<br><br>Example of variable deployment :<pre>vpc_peerings = {<br>  "trust-to-spoke1" = {<br>    local_network = "fw-trust-vpc"<br>    peer_network  = "spoke1-vpc"<br><br>    local_export_custom_routes                = true<br>    local_import_custom_routes                = true<br>    local_export_subnet_routes_with_public_ip = true<br>    local_import_subnet_routes_with_public_ip = true<br><br>    peer_export_custom_routes                = true<br>    peer_import_custom_routes                = true<br>    peer_export_subnet_routes_with_public_ip = true<br>    peer_import_subnet_routes_with_public_ip = true<br>  }<br>}</pre>For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/vpc-peering#inputs)<br><br>Multiple keys can be added and will be deployed by the code. | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lbs_external_ips_region_1"></a> [lbs\_external\_ips\_region\_1](#output\_lbs\_external\_ips\_region\_1) | Public IP addresses of external network loadbalancers in region-1. |
| <a name="output_lbs_external_ips_region_2"></a> [lbs\_external\_ips\_region\_2](#output\_lbs\_external\_ips\_region\_2) | Public IP addresses of external network loadbalancers in region-2. |
| <a name="output_lbs_internal_ips_region_1"></a> [lbs\_internal\_ips\_region\_1](#output\_lbs\_internal\_ips\_region\_1) | Private IP addresses of internal network loadbalancers in region-1. |
| <a name="output_lbs_internal_ips_region_2"></a> [lbs\_internal\_ips\_region\_2](#output\_lbs\_internal\_ips\_region\_2) | Private IP addresses of internal network loadbalancers in region-2. |
| <a name="output_linux_vm_ips_region_1"></a> [linux\_vm\_ips\_region\_1](#output\_linux\_vm\_ips\_region\_1) | Private IP addresses of Linux VMs in region-1. |
| <a name="output_linux_vm_ips_region_2"></a> [linux\_vm\_ips\_region\_2](#output\_linux\_vm\_ips\_region\_2) | Private IP addresses of Linux VMs in region-2. |
| <a name="output_vmseries_private_ips_region_1"></a> [vmseries\_private\_ips\_region\_1](#output\_vmseries\_private\_ips\_region\_1) | Private IP addresses of the vmseries instances in region-1. |
| <a name="output_vmseries_private_ips_region_2"></a> [vmseries\_private\_ips\_region\_2](#output\_vmseries\_private\_ips\_region\_2) | Private IP addresses of the vmseries instances in region-2. |
| <a name="output_vmseries_public_ips_region_1"></a> [vmseries\_public\_ips\_region\_1](#output\_vmseries\_public\_ips\_region\_1) | Public IP addresses of the vmseries instances in region-1. |
| <a name="output_vmseries_public_ips_region_2"></a> [vmseries\_public\_ips\_region\_2](#output\_vmseries\_public\_ips\_region\_2) | Public IP addresses of the vmseries instances in region-2. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
