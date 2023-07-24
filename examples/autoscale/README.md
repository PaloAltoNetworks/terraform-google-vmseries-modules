---
show_in_hub: false
---
# Deployment of Palo Alto Networks VM-Series Firewalls with Autoscaling

## Overview
This example deploys VM-Series firewalls through a Managed Instance Group (MIG). The MIG enables the VM-Series to horizontally scale (i.e. do autoscaling) based on custom PAN-OS metrics delivered to Google Cloud Monitoring by Panorama. There are 10 custom metric that are delivered:
- VMSeries/DataPlaneCPUUtilizationPct
- VMSeries/panSessionConnectionsPerSecond
- VMSeries/panSessionThroughputKbps
- VMSeries/panSessionThroughputPps
- VMSeries/DataPlanePacketBufferUtilization
- VMSeries/panGPGatewayUtilizationPct
- VMSeries/panGPGWUtilizationActiveTunnels
- VMSeries/panSessionActive
- VMSeries/panSessionSslProxyUtilization
- VMSeries/panSessionUtilization

GCP Autoscaler adds or deletes VM instances from a managed instance group based on the group's autoscaling policy that is set in `autoscale` module.

```
resource "google_compute_autoscaler" "zonal" {
  for_each = var.regional_mig ? {} : var.zones
  ...

  autoscaling_policy {
    min_replicas    = var.min_vmseries_replicas
    max_replicas    = var.max_vmseries_replicas
    cooldown_period = var.cooldown_period

    dynamic "metric" {
      for_each = var.autoscaler_metrics
      content {
        name   = metric.key
        type   = try(metric.value.type, "GAUGE")
        target = metric.value.target
      }
    }

    scale_in_control {
      time_window_sec = var.scale_in_control_time_window_sec
      max_scaled_in_replicas {
        fixed = var.scale_in_control_replicas_fixed
      }
    }
  }
}
```

### VM-Series licensing
There are at least 2 options for VM-Series licensing for autoscaling. These options are different in the way how you can free up licenses (delicense) when MIG scales in.
1. An authcode is set in VM-Series bootstrap parameters. [Delicesing can be done manually](https://docs.paloaltonetworks.com/vm-series/10-1/vm-series-deployment/license-the-vm-series-firewall/vm-series-models/deactivate-the-licenses/deactivate-vm)
2. An authcode is assigned to Device Group through [Panorama Software Firewall License Plugin](https://docs.paloaltonetworks.com/vm-series/10-1/vm-series-deployment/license-the-vm-series-firewall/use-panorama-based-software-firewall-license-management). Delicensing can happen automatically according to Software Firewall License Plugin settings. However due to how Software Firewall License Plugin works after scale-in event there is at least 1h delay before delicensing is actually heppanening.

To speed up delicensing, `autoscale` module and this example introduce optional delicensing Cloud Function that works in conjunction with Software Firewall License Plugin. The Cloud Function is triggered on MIG scale-in event, connects to Panorama and requests the plugin to delicense deleted VM-Series instance without any delay.

To enable the Cloud Function use instructions below to set `delicensing_cloud_function_config`.

### Created resources

Created resources include:
* 3 x VPC Networks (`mgmt`, `untrust/public`, and `trust/hub` VPC networks).
* 1 x Service Account
* 1 x Managed Instance Group.
* 1 x Internal TCP/UDP load balancer to distribute egress traffic to VM-Series trust/hub interfaces.
* 1 x External TCP/UDP load balancer to distribute internet inbound traffic to VM-Series untrust/public interfaces.
* 1 x Pub/Sub Topic and Subscription


![image](https://user-images.githubusercontent.com/2110772/188896518-1fe5abd2-1887-4c2f-bc63-95c6a03bbb4e.png)

(Optional) Delicensing Cloud Function:

* 1 x Log router
* 1 x Pub/Sub Topic 
* 1 x Service Account
* 1 x Storage Bucket
* 1 x Serverless VPC Access connector
* 1 x Secret Manager secret
* 1 x Cloud Function

(Optional) Test VMs:

* N x Compute Engine VMs

## Requirements

1. A Panorama appliance with network connectivity over `TCP/443` & `TCP/3978` from the VM-Series MGMT interfaces. This example assumes VM-Series instances connect to Panorama over the internet.

> If you do not have a Panorama appliance, please see `examples/panorama` to deploy Panorama on Google Cloud.

2. A Panorama `Device Group`, `Template Stack`, and [`VM Authorization Key`](https://docs.paloaltonetworks.com/vm-series/10-1/vm-series-deployment/bootstrap-the-vm-series-firewall/generate-the-vm-auth-key-on-panorama). These values are required to bootstrap the VM-Series firewalls to Panorama.
3. (For BYOL VM-Series licensing only) An authcode is assigned to Device Group through [Panorama Software Firewall License Plugin](https://docs.paloaltonetworks.com/vm-series/10-1/vm-series-deployment/license-the-vm-series-firewall/use-panorama-based-software-firewall-license-management).
 If delicensing Cloud Function is used it requires that VM-Series use Panorama Software Firewall License Plugin for licensing.

> For information on staging Panorama for VM-Series MIGs, see:
> * [Panorama Staging for VM-Series MIGs](docs/panorama-staging-vmseries-migs.md)
> * [Autoscaling Components for Google Cloud](https://docs.paloaltonetworks.com/vm-series/9-1/vm-series-deployment/set-up-the-vm-series-firewall-on-google-cloud-platform/autoscaling-on-google-cloud-platform/autoscaling-components-for-gcp#id17COG5060BX)


## Deploy

1. Access a machine with Terraform installed or click **Open in Google Cloud Shell**.

<p align="center" width="100%">
  <a href="https://ssh.cloud.google.com/cloudshell/editor"><img width="350" src="https://user-images.githubusercontent.com/2110772/188896668-23fc9260-642a-4b7f-b64f-8e0b783b598a.png">
  </a>
</p>

2. Enable the required APIs, clone the Github repository, and change directories to the example build.

```
gcloud services enable compute.googleapis.com
git clone https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules
cd terraform-google-vmseries-modules/examples/autoscale
```

3. Create a file named `terraform.tfvars` in a text editor of your choice (i.e. Cloud Shell Editor, `vim`, or `nano`) or copy an existing sample `example.tfvars` file.

4. If created from scratch, paste the variables below into your `terraform.tfvars`. Modify the values to match your environment. A description of each variable can be found in [variables.tf](variables.tf).
```
project_id  = "my-project-id"
name_prefix = "example-"
region      = "us-central1"

cidr_mgmt       = "10.0.0.0/28"
cidr_untrust    = "10.0.1.0/28"
cidr_trust      = "10.0.2.0/28"
allowed_sources = ["0.0.0.0/0"]

vmseries_image_name    = "https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/vmseries-flex-byol-1023"
vmseries_instances_min = 1
vmseries_instances_max = 2

panorama_address        = "1.1.1.1"
panorama_device_group   = "autoscale-device-group"
panorama_template_stack = "autoscale-template-stack"
panorama_vm_auth_key    = "01234567890123456789"
```
5. (Optional) If you would like to deploy zonal MIGs instead of regional MIGs, make the following changes in [`main.tf`](main.tf).
    * Within `module "autoscale"`, add the `zones` parameter and set `regional_mig=false`.
    * Within `module "intlb"`, configure backends parameter to use each output for `zonal_instance_group_ids`.

<pre>
module "autoscale" {
  source = "PaloAltoNetworks/vmseries-modules/google//modules/autoscale"

  name             = "${local.prefix}vmseries"
  region           = "us-central1"
  <b>regional_mig = false</b>
  <b>zones = {
    zone1 = "us-central1-a"
    zone2 = "us-central1-b"
  }</b>
  ...
  ...
}
...
...
module "intlb" {
  source = "PaloAltoNetworks/vmseries-modules/google//modules/lb_internal"

  name              = "${local.prefix}internal-lb"
  network           = data.google_compute_subnetwork.trust.network
  subnetwork        = data.google_compute_subnetwork.trust.self_link
  all_ports         = true
  health_check_port = 80
  backends = {
    <b>backend1 = module.autoscale.zonal_instance_group_ids["zone1"]
    backend2 = module.autoscale.zonal_instance_group_ids["zone2"]</b>
  }
  allow_global_access = true
}
</pre>

6. (Optional) Configure [Panorama Software Firewall License Plugin](https://docs.paloaltonetworks.com/vm-series/10-1/vm-series-deployment/license-the-vm-series-firewall/use-panorama-based-software-firewall-license-management)

> **Note:** For delicensing Cloud Function to work it is required that 
`License manager` name is exactly the same as VM-Series MIG name.

Make sure you are using `panorama_auth_key` from Panorama Software Firewall License Plugin in `terraform.tfvars`. `panorama_vm_auth_key` should NOT be used (commented out or deleted).

```
# panorama_vm_auth_key = "01234567890123456789"
panorama_auth_key      = "_XX__0qweryQWERTYqwertyQWERTGrp"
```

7. (Optional) If you would like to configure Cloud Function for VM-Series delicensing on MIG scale-in event add `delicensing_cloud_function_config` to `terraform.tfvars`.

```
delicensing_cloud_function_config = {
  name_prefix           = "abc-"
  panorama_ip           = "1.1.1.1"
  vpc_connector_network = "panorama-vpc"
  vpc_connector_cidr    = "10.254.190.64/28"
  region                = "us-central1"
  bucket_location       = "US"
}
```

8. (Optional) If you would like to have VMs to test autoscaling add `test_vms` to `terraform.tfvars`.

```
  test_vms = {
    "vm1" = {
      "zone" : "us-central1-a"
      "machine_type": "e2-micro"
    }
  }
```

9. Save your `terraform.tfvars` and deploy.

```
terraform init
terraform apply
```
> **Note:** The health probes on the external load balancer be down. This is because a service must be configured behind the firewall to respond to the load balancer's health probes.

10. (Optional) If you are using delicensing Cloud Function remember to set Panorama credentials in the Secret Manager secret created by Terraform.
Credentials use `|` as delimiter. Example: `admin|password`

11. (Optional) Configure Security policies and NAT Run hping3 utility from test VM to generate sessions to trigger scale-out event.

```
hping3 -1 -i u10000 <target IP>
```

## Reference
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2, < 2.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 4.58 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 4.58 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_autoscale"></a> [autoscale](#module\_autoscale) | ../../modules/autoscale/ | n/a |
| <a name="module_extlb"></a> [extlb](#module\_extlb) | ../../modules/lb_external/ | n/a |
| <a name="module_iam_service_account"></a> [iam\_service\_account](#module\_iam\_service\_account) | ../../modules/iam_service_account/ | n/a |
| <a name="module_intlb"></a> [intlb](#module\_intlb) | ../../modules/lb_internal/ | n/a |
| <a name="module_mgmt_cloud_nat"></a> [mgmt\_cloud\_nat](#module\_mgmt\_cloud\_nat) | terraform-google-modules/cloud-nat/google | =1.2 |
| <a name="module_vpc_mgmt"></a> [vpc\_mgmt](#module\_vpc\_mgmt) | terraform-google-modules/network/google | ~> 4.0 |
| <a name="module_vpc_trust"></a> [vpc\_trust](#module\_vpc\_trust) | terraform-google-modules/network/google | ~> 4.0 |
| <a name="module_vpc_untrust"></a> [vpc\_untrust](#module\_vpc\_untrust) | terraform-google-modules/network/google | ~> 4.0 |

### Resources

| Name | Type |
|------|------|
| [google_compute_instance.test_vm](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_service_account.test_vm](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_compute_image.ubuntu](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_sources"></a> [allowed\_sources](#input\_allowed\_sources) | A list of IP addresses to be added to the management network's ingress firewall rule. The IP addresses will be able to access to the VM-Series management interface. | `list(string)` | n/a | yes |
| <a name="input_authcodes"></a> [authcodes](#input\_authcodes) | VM-Series authcodes. | `string` | `null` | no |
| <a name="input_autoscaler_metrics"></a> [autoscaler\_metrics](#input\_autoscaler\_metrics) | The map with the keys being metrics identifiers (e.g. custom.googleapis.com/VMSeries/panSessionUtilization).<br>Each of the contained objects has attribute `target` which is a numerical threshold for a scale-out or a scale-in.<br>Each zonal group grows until it satisfies all the targets.<br><br>Additional optional attribute `type` defines the metric as either `GAUGE` (the default), `DELTA_PER_SECOND`, or `DELTA_PER_MINUTE`.<br>For full specification, see the `metric` inside the [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_autoscaler). | `map` | <pre>{<br>  "custom.googleapis.com/VMSeries/panSessionActive": {<br>    "target": 100<br>  }<br>}</pre> | no |
| <a name="input_cidr_mgmt"></a> [cidr\_mgmt](#input\_cidr\_mgmt) | The CIDR range of the management subnetwork. | `string` | `"10.0.0.0/28"` | no |
| <a name="input_cidr_trust"></a> [cidr\_trust](#input\_cidr\_trust) | The CIDR range of the trust subnetwork. | `string` | `"10.0.2.0/28"` | no |
| <a name="input_cidr_untrust"></a> [cidr\_untrust](#input\_cidr\_untrust) | The CIDR range of the untrust subnetwork. | `string` | `"10.0.1.0/28"` | no |
| <a name="input_delicensing_cloud_function_config"></a> [delicensing\_cloud\_function\_config](#input\_delicensing\_cloud\_function\_config) | Defining `delicensing_cloud_function_config` enables creation of delicesing cloud function and related resources.<br>The variable contains the following configuration parameters that are related to Cloud Function:<br>- `name_prefix`           - Resource name prefix<br>- `function_name`         - Cloud Function base name<br>- `region`                - Cloud Function region<br>- `bucket_location`       - Cloud Function source code bucket location <br>- `panorama_address`      - Panorama IP address/FQDN<br>- `vpc_connector_network` - Panorama VPC network Name<br>- `vpc_connector_cidr`    - VPC connector /28 CIDR.<br>                            VPC connector will be user for delicensing CFN to access Panorama VPC network.<br> <br>Example:<pre>{<br>  name_prefix           = "abc-"<br>  function_name         = "delicensing-cfn"<br>  region                = "us-central1"<br>  bucket_location       = "US"<br>  panorama_address      = "1.1.1.1"<br>  vpc_connector_network = "panorama-vpc"<br>  vpc_connector_cidr    = "10.10.190.0/28"<br>}</pre> | <pre>map(object({<br>    name_prefix           = optional(string)<br>    function_name         = optional(string)<br>    region                = string<br>    bucket_location       = string<br>    panorama_address      = string<br>    vpc_connector_network = string<br>    vpc_connector_cidr    = string<br>  }))</pre> | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix to prepend the resource names. This is useful for identifing the created resources. | `string` | `""` | no |
| <a name="input_panorama_address"></a> [panorama\_address](#input\_panorama\_address) | The Panorama IP address/FQDN.  The Panorama must be reachable from the management VPC. This build assumes Panorama is reachable via the internet. The management VPC network uses a NAT gateway to communicate to Panorama's external IP addresses. | `string` | n/a | yes |
| <a name="input_panorama_auth_key"></a> [panorama\_auth\_key](#input\_panorama\_auth\_key) | Panorama authorization key.  To generate, follow this guide https://docs.paloaltonetworks.com/vm-series/9-1/vm-series-deployment/license-the-vm-series-firewall/use-panorama-based-software-firewall-license-management | `string` | `null` | no |
| <a name="input_panorama_device_group"></a> [panorama\_device\_group](#input\_panorama\_device\_group) | The name of the Panorama device group that will bootstrap the VM-Series firewalls. | `string` | n/a | yes |
| <a name="input_panorama_template_stack"></a> [panorama\_template\_stack](#input\_panorama\_template\_stack) | The name of the Panorama template stack that will bootstrap the VM-Series firewalls. | `string` | n/a | yes |
| <a name="input_panorama_vm_auth_key"></a> [panorama\_vm\_auth\_key](#input\_panorama\_vm\_auth\_key) | Panorama VM authorization key.  To generate, follow this guide https://docs.paloaltonetworks.com/vm-series/10-1/vm-series-deployment/bootstrap-the-vm-series-firewall/generate-the-vm-auth-key-on-panorama.html | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project ID to contain the created cloud resources. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP region | `string` | n/a | yes |
| <a name="input_ssh_keys"></a> [ssh\_keys](#input\_ssh\_keys) | VM-Series SSH keys. Format: 'admin:<ssh-rsa AAAA...>' | `string` | `""` | no |
| <a name="input_test_vms"></a> [test\_vms](#input\_test\_vms) | Test VMs<br><br>Example:<pre>{<br>  "vm1" = {<br>    "zone" : "us-central1-a"<br>    "machine_type": "e2-micro"<br>  }<br>}</pre> | <pre>map(object({<br>    zone         = string<br>    machine_type = string<br>  }))</pre> | `{}` | no |
| <a name="input_vmseries_image_name"></a> [vmseries\_image\_name](#input\_vmseries\_image\_name) | Link to VM-Series PAN-OS image. Can be either a full self\_link, or one of the shortened forms per the [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#image). | `string` | n/a | yes |
| <a name="input_vmseries_instances_max"></a> [vmseries\_instances\_max](#input\_vmseries\_instances\_max) | The maximum number of VM-Series that the autoscaler can scale up to. This is required when creating or updating an autoscaler. The maximum number of VM-Series should not be lower than minimal number of VM-Series. | `number` | `5` | no |
| <a name="input_vmseries_instances_min"></a> [vmseries\_instances\_min](#input\_vmseries\_instances\_min) | The minimum number of VM-Series that the autoscaler can scale down to. This cannot be less than 0. | `number` | `2` | no |
| <a name="input_vmseries_machine_type"></a> [vmseries\_machine\_type](#input\_vmseries\_machine\_type) | (Optional) The instance type for the VM-Series firewalls. | `string` | `"n2-standard-4"` | no |

### Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2, < 2.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 4.58 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.73.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_autoscale"></a> [autoscale](#module\_autoscale) | ../../modules/autoscale/ | n/a |
| <a name="module_extlb"></a> [extlb](#module\_extlb) | ../../modules/lb_external/ | n/a |
| <a name="module_iam_service_account"></a> [iam\_service\_account](#module\_iam\_service\_account) | ../../modules/iam_service_account/ | n/a |
| <a name="module_intlb"></a> [intlb](#module\_intlb) | ../../modules/lb_internal/ | n/a |
| <a name="module_mgmt_cloud_nat"></a> [mgmt\_cloud\_nat](#module\_mgmt\_cloud\_nat) | terraform-google-modules/cloud-nat/google | =1.2 |
| <a name="module_vpc_mgmt"></a> [vpc\_mgmt](#module\_vpc\_mgmt) | terraform-google-modules/network/google | ~> 4.0 |
| <a name="module_vpc_trust"></a> [vpc\_trust](#module\_vpc\_trust) | terraform-google-modules/network/google | ~> 4.0 |
| <a name="module_vpc_untrust"></a> [vpc\_untrust](#module\_vpc\_untrust) | terraform-google-modules/network/google | ~> 4.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_instance.test_vm](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_image.ubuntu](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_sources"></a> [allowed\_sources](#input\_allowed\_sources) | A list of IP addresses to be added to the management network's ingress firewall rule. The IP addresses will be able to access to the VM-Series management interface. | `list(string)` | n/a | yes |
| <a name="input_autoscaler_metrics"></a> [autoscaler\_metrics](#input\_autoscaler\_metrics) | The map with the keys being metrics identifiers (e.g. custom.googleapis.com/VMSeries/panSessionUtilization).<br>Each of the contained objects has attribute `target` which is a numerical threshold for a scale-out or a scale-in.<br>Each zonal group grows until it satisfies all the targets.<br><br>Additional optional attribute `type` defines the metric as either `GAUGE` (the default), `DELTA_PER_SECOND`, or `DELTA_PER_MINUTE`.<br>For full specification, see the `metric` inside the [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_autoscaler). | `map` | <pre>{<br>  "custom.googleapis.com/VMSeries/panSessionActive": {<br>    "target": 100<br>  }<br>}</pre> | no |
| <a name="input_cidr_mgmt"></a> [cidr\_mgmt](#input\_cidr\_mgmt) | The CIDR range of the management subnetwork. | `string` | `"10.0.0.0/28"` | no |
| <a name="input_cidr_trust"></a> [cidr\_trust](#input\_cidr\_trust) | The CIDR range of the trust subnetwork. | `string` | `"10.0.2.0/28"` | no |
| <a name="input_cidr_untrust"></a> [cidr\_untrust](#input\_cidr\_untrust) | The CIDR range of the untrust subnetwork. | `string` | `"10.0.1.0/28"` | no |
| <a name="input_delicensing_cloud_function_config"></a> [delicensing\_cloud\_function\_config](#input\_delicensing\_cloud\_function\_config) | Defining `delicensing_cloud_function_config` enables creation of delicesing cloud function and related resources.<br>The variable contains the following configuration parameters that are related to Cloud Function:<br>- name\_prefix - Resource name prefix<br>- function\_name - Cloud Function base name<br>- region - Cloud Function region<br>- bucket\_location - Cloud Function source code bucket location <br>- panorama\_ip - Panorama IP address<br>- vpc\_connector\_network - Panorama VPC network Name<br>- vpc\_connector\_cidr - VPC connector /28 CIDR.<br>  VPC connector will be user for delicensing CFN to access Panorama VPC network.<br> <br><br>Example:<pre>{<br>  name_prefix           = "abc-"<br>  function_name         = "delicensing-cfn"<br>  region                = "europe-central1"<br>  bucket_location       = "EU"<br>  panorama_ip           = "1.1.1.1"<br>  vpc_connector_network = "panorama-vpc"<br>  vpc_connector_cidr    = "10.10.190.0/28"<br>}</pre> | `any` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix to prepend the resource names. This is useful for identifing the created resources. | `string` | `""` | no |
| <a name="input_panorama_address"></a> [panorama\_address](#input\_panorama\_address) | The Panorama IP/Domain address.  The Panorama address must be reachable from the management VPC. This build assumes Panorama is reachable via the internet. The management VPC network uses a NAT gateway to communicate to Panorama's external IP addresses. | `string` | n/a | yes |
| <a name="input_panorama_auth_key"></a> [panorama\_auth\_key](#input\_panorama\_auth\_key) | Panorama authorization key.  To generate, follow this guide https://docs.paloaltonetworks.com/vm-series/9-1/vm-series-deployment/license-the-vm-series-firewall/use-panorama-based-software-firewall-license-management | `string` | `null` | no |
| <a name="input_panorama_device_group"></a> [panorama\_device\_group](#input\_panorama\_device\_group) | The name of the Panorama device group that will bootstrap the VM-Series firewalls. | `string` | n/a | yes |
| <a name="input_panorama_template_stack"></a> [panorama\_template\_stack](#input\_panorama\_template\_stack) | The name of the Panorama template stack that will bootstrap the VM-Series firewalls. | `string` | n/a | yes |
| <a name="input_panorama_vm_auth_key"></a> [panorama\_vm\_auth\_key](#input\_panorama\_vm\_auth\_key) | Panorama VM authorization key.  To generate, follow this guide https://docs.paloaltonetworks.com/vm-series/10-1/vm-series-deployment/bootstrap-the-vm-series-firewall/generate-the-vm-auth-key-on-panorama.html | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project ID to contain the created cloud resources. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP region | `string` | n/a | yes |
| <a name="input_ssh_keys"></a> [ssh\_keys](#input\_ssh\_keys) | VM-Series SSH keys. Format: 'admin:<ssh-rsa AAAA...>' | `string` | `""` | no |
| <a name="input_test_vm_zone"></a> [test\_vm\_zone](#input\_test\_vm\_zone) | n/a | `string` | `""` | no |
| <a name="input_test_vms"></a> [test\_vms](#input\_test\_vms) | List ot test VM names | `list(string)` | `[]` | no |
| <a name="input_vmseries_image_name"></a> [vmseries\_image\_name](#input\_vmseries\_image\_name) | Link to VM-Series PAN-OS image. Can be either a full self\_link, or one of the shortened forms per the [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#image). | `string` | n/a | yes |
| <a name="input_vmseries_instances_max"></a> [vmseries\_instances\_max](#input\_vmseries\_instances\_max) | The maximum number of VM-Series that the autoscaler can scale up to. This is required when creating or updating an autoscaler. The maximum number of VM-Series should not be lower than minimal number of VM-Series. | `number` | `5` | no |
| <a name="input_vmseries_instances_min"></a> [vmseries\_instances\_min](#input\_vmseries\_instances\_min) | The minimum number of VM-Series that the autoscaler can scale down to. This cannot be less than 0. | `number` | `2` | no |
| <a name="input_vmseries_machine_type"></a> [vmseries\_machine\_type](#input\_vmseries\_machine\_type) | (Optional) The instance type for the VM-Series firewalls. | `string` | `"n2-standard-4"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->