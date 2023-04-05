# Palo Alto Panorama deployment example

## Overview

The scope of this code is to deploy one or more panorama instances in a single project and region in Google Cloud.

Important information :

 - The code builds a single region topology for panorama
 - VPCs and subnetwork(s) can be created or read from existing infrastructure
 - Variable construction is documented below

## Topology

The topology for this build as it is pre-completed in the tfvars file is fairly basic consisting of :
 - A VPC and a subnetwork
 - A panorama instance with a Public IP address attached to the created subnetwork
 - Firewall rules that allow access to the panorama management interface

![panorama-topology](https://user-images.githubusercontent.com/43091730/230029801-3acea62e-aa3d-46f3-b638-6b09bf5ef35e.png)

## Build

1. Access Google Cloud Shell or any other environment which has access to your GCP project

2. Clone the repository and fill out any modifications to tfvars file (`panorama-example.tfvars` - at least `project`, `ssh_keys` and `allowed_sources` should be filled in for successful deployment and access to the instanceafter deployment)

```
git clone https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules
cd terraform-google-vmseries-modules/examples/panorama
```

3. Apply the terraform code

```
terraform init
terraform apply -var-file=panorama-example.tfvars
```

4. Check the output plan and confirm the apply

5. Check the successful application and outputs of the resulting infrastructure:

```
Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

Outputs:

panorama_private_ip = {
  "panorama-01" = "172.21.21.2"
}
panorama_public_ip = {
  "panorama-01" = "x.x.x.x"
}
```


## Post build

Connect to the panorama instance via SSH using your associated private key and set a password :

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

Use a web browser to access https://x.x.x.x and login with admin and your previously configured password

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0, < 2.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_panorama"></a> [panorama](#module\_panorama) | ../../modules/panorama | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../../modules/vpc | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A string to prefix resource namings | `string` | `"example-"` | no |
| <a name="input_networks"></a> [networks](#input\_networks) | A map containing each network setting.<br><br>Example of variable deployment :<pre>vpcs = {<br>  "panorama-vpc" = {<br>    vpc_name          = "panorama-vpc"<br>    subnet_name       = "example-panorama-subnet"<br>    cidr              = "172.21.21.0/24"<br>    allowed_sources   = ["1.1.1.1/32" , "2.2.2.2/32"]<br>    create_network    = true<br>    create_subnetwork = true<br>  }<br>}</pre>For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/vpc#input_networks)<br><br>Multiple keys can be added and will be deployed by the code | `any` | n/a | yes |
| <a name="input_panoramas"></a> [panoramas](#input\_panoramas) | A map containing each panorama setting.<br><br>Example of variable deployment :<pre>panoramas = {<br>  "panorama-01" = {<br>    panorama_name     = "panorama-01"<br>    panorama_vpc      = "panorama-vpc"<br>    panorama_subnet   = "example-panorama-subnet"<br>    panorama_version  = "panorama-byol-1000"<br>    ssh_keys          = "admin:<PUBLIC-KEY>"<br>    attach_public_ip  = true<br>    private_static_ip = "172.21.21.2"<br><br>    log_disks = [<br>      {<br>        name = "example-panorama-disk-1"<br>        type = "pd-ssd"<br>        size = "2000"<br>      },<br>      {<br>        name = "example-panorama-disk-2"<br>        type = "pd-ssd"<br>        size = "2000"<br>      },<br>    ]<br>  }<br>}</pre>For a full list of available configuration items - please refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/tree/main/modules/panorama#inputs)<br><br>Multiple keys can be added and will be deployed by the code | `any` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | The project name to deploy the infrastructure in to. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | The region into which to deploy the infrastructure in to | `string` | `"us-central1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_panorama_private_ip"></a> [panorama\_private\_ip](#output\_panorama\_private\_ip) | Private IP address of the Panorama instance. |
| <a name="output_panorama_public_ip"></a> [panorama\_public\_ip](#output\_panorama\_public\_ip) | Public IP address of the Panorama instance. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
