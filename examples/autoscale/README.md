# Deployment of Palo Alto Networks VM-Series Firewalls with Autoscaling

This example deploys VM-Series firewalls into a managed instance group.  The VM-Series firewalls can be scaled horizontally based on custom PAN-OS metrics delivered to Google Stackdriver.

For managed instance group deployments, it is highly recommended to bootstrap the VM-Series firewalls to Panorama for automatic configuration.  

## Instructions

1. Set up Panorama on-premises or in a VPC network (consider using `examples/panorama`).  
   * Panorama must have network connectivity to the management VPC network created in this example build. 
   * If you already have a management VPC network, perform the following in `main.tf`:
     1. Replace `module "vpc_mgmt"` with <a href="https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork">`data google_compute_subnetwork`</a> to pull your existing management subnetwork.  
     2. Within the the VM-Series `autoscale` module, set the management NIC to use your data resource in the previous step.  For example:

<pre><b>
data "google_compute_subnetwork" "mgmt" {
    name   = "default-us-east1"
    region = var.region
}</b>

....
....

module "autoscale" {
source = "../../modules/autoscale"

zones = {
    zone1 = data.google_compute_zones.main.names[0]
    zone2 = data.google_compute_zones.main.names[1]
}

prefix                = "${local.prefix}vmseries-mig"
deployment_name       = "${local.prefix}vmseries-mig-deployment"
machine_type          = var.vmseries_machine_type
image                 = var.vmseries_image_name
pool                  = module.extlb.target_pool
scopes                = ["https://www.googleapis.com/auth/cloud-platform"]
service_account_email = module.iam_service_account.email
min_replicas_per_zone = var.vmseries_per_zone_min  // min firewalls per zone.
max_replicas_per_zone = var.vmseries_per_zone_max  // max firewalls per zone.
autoscaler_metrics    = var.autoscaler_metrics

network_interfaces = [
    {
        subnetwork       = module.vpc_untrust.subnets_self_links[0]
        create_public_ip = true
    },
    {
        subnetwork       = <b>data.google_compute_subnetwork.mgmt.self_link</b>
        create_public_ip = false 
    },
    {
        subnetwork       = module.vpc_trust.subnets_self_links[0]
        create_public_ip = false
    }
]

....
....
</pre>

3. On Panorama, create a <a href="https://docs.paloaltonetworks.com/panorama/10-2/panorama-admin/manage-firewalls/manage-device-groups/add-a-device-group">Device Group</a>, <a href="https://docs.paloaltonetworks.com/panorama/10-2/panorama-admin/manage-firewalls/manage-templates-and-template-stacks/configure-a-template-stack">Template Stack</a>, and generate a <a href="https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/bootstrap-the-vm-series-firewall/generate-the-vm-auth-key-on-panorama">VM Auth Key</a>.
4. Copy the example.tfvars into terraform.tfvars. Modify the values within terraform.tfvars to match your deployment.


## Deploy Terraform

```
terraform init
terraform plan
terraform apply
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.3, < 2.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 3.48 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 3.48 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_autoscale"></a> [autoscale](#module\_autoscale) | ../../modules/autoscale | n/a |
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
| [google_compute_zones.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_sources"></a> [allowed\_sources](#input\_allowed\_sources) | A list of IP addresses to be added to the management network's ingress firewall rule. The IP addresses will be able to access to the VM-Series management interface. | `list(string)` | `null` | no |
| <a name="input_autoscaler_metrics"></a> [autoscaler\_metrics](#input\_autoscaler\_metrics) | The map with the keys being metrics identifiers (e.g. custom.googleapis.com/VMSeries/panSessionUtilization).<br>Each of the contained objects has attribute `target` which is a numerical threshold for a scale-out or a scale-in.<br>Each zonal group grows until it satisfies all the targets.<br><br>Additional optional attribute `type` defines the metric as either `GAUGE` (the default), `DELTA_PER_SECOND`, or `DELTA_PER_MINUTE`.<br>For full specification, see the `metric` inside the [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_autoscaler). | `map` | <pre>{<br>  "custom.googleapis.com/VMSeries/panSessionActive": {<br>    "target": 100<br>  }<br>}</pre> | no |
| <a name="input_cidr_mgmt"></a> [cidr\_mgmt](#input\_cidr\_mgmt) | The CIDR range of the management subnetwork. | `string` | `null` | no |
| <a name="input_cidr_trust"></a> [cidr\_trust](#input\_cidr\_trust) | The CIDR range of the trust subnetwork. | `string` | `null` | no |
| <a name="input_cidr_untrust"></a> [cidr\_untrust](#input\_cidr\_untrust) | The CIDR range of the untrust subnetwork. | `string` | `null` | no |
| <a name="input_panorama_address"></a> [panorama\_address](#input\_panorama\_address) | The Panorama IP/Domain address.  The Panorama address must be reachable from the management VPC.<br>This build assumes Panorama is reachable via the internet. The management VPC network uses a <br>NAT gateway to communicate to Panorama's external IP addresses. | `string` | n/a | yes |
| <a name="input_panorama_device_group"></a> [panorama\_device\_group](#input\_panorama\_device\_group) | The name of the Panorama device group that will bootstrap the VM-Series firewalls. | `string` | n/a | yes |
| <a name="input_panorama_template_stack"></a> [panorama\_template\_stack](#input\_panorama\_template\_stack) | The name of the Panorama template stack that will bootstrap the VM-Series firewalls. | `string` | n/a | yes |
| <a name="input_panorama_vm_auth_key"></a> [panorama\_vm\_auth\_key](#input\_panorama\_vm\_auth\_key) | Panorama VM authorization key.  To generate, follow this guide https://docs.paloaltonetworks.com/vm-series/10-1/vm-series-deployment/bootstrap-the-vm-series-firewall/generate-the-vm-auth-key-on-panorama.html | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to GCP resource names, an arbitrary string | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project ID | `string` | n/a | yes |
| <a name="input_public_key_path"></a> [public\_key\_path](#input\_public\_key\_path) | Local path to public SSH key. To generate the key pair use `ssh-keygen -t rsa -C admin -N '' -f id_rsa`  If you do not have a public key, run `ssh-keygen -f ~/.ssh/demo-key -t rsa -C admin` | `string` | `"~/.ssh/gcp-demo.pub"` | no |
| <a name="input_region"></a> [region](#input\_region) | GCP Region | `string` | `"us-east1"` | no |
| <a name="input_vmseries_image_name"></a> [vmseries\_image\_name](#input\_vmseries\_image\_name) | Link to VM-Series PAN-OS image. Can be either a full self\_link, or one of the shortened forms per the [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#image). | `string` | `"https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/vmseries-flex-byol-1014"` | no |
| <a name="input_vmseries_machine_type"></a> [vmseries\_machine\_type](#input\_vmseries\_machine\_type) | The Google Compute instance type to run the VM-Series firewall.  N1 and N2 instance types are supported. | `string` | `"n1-standard-4"` | no |
| <a name="input_vmseries_per_zone_max"></a> [vmseries\_per\_zone\_max](#input\_vmseries\_per\_zone\_max) | The max number of firewalls to run in each zone. | `number` | `2` | no |
| <a name="input_vmseries_per_zone_min"></a> [vmseries\_per\_zone\_min](#input\_vmseries\_per\_zone\_min) | The minimum number of firewalls to run in each zone. | `number` | `1` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
