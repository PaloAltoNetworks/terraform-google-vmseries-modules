# VM-Series Reference Architecture - Common Deployment Option

## Audience

This guide is for technical readers, including system architects and design engineers, who want to deploy the Palo Alto Networks VM-Series firewalls and Panorama within a public-cloud infrastructure. This guide assumes the reader is familiar with the basic concepts of applications, networking, virtualization, security, high availability, as well as public cloud concepts with specific focus on GCP.

## Introduction

There are many design models which can be used to secure application environments in GCP. Palo Alto Networks produces [validated reference architecture design and deployment documentation](https://www.paloaltonetworks.com/resources/reference-architectures), which guides towards the best security outcomes, reducing rollout time and avoiding common integration efforts. These architectures are designed, tested, and documented to provide faster, predictable deployments.

This guide uses a VPC Peering design. Application functions are distributed across multiple projects that are connected in a logical hub-and-spoke topology. A security project acts as the hub, providing centralized connectivity and control for multiple application projects. You deploy all VM-Series firewalls within the security project. The spoke projects contain the workloads and necessary services to support the application deployment.
This design model integrates multiple methods to interconnect and control your application project VPC networks with resources in the security project. VPC Peering enables the private VPC network in the security project to peer with, and share routing information to, each application project VPC network. Using Shared VPC, the security project administrators create and share VPC network resources from within the security project to the application projects. The application project administrators can select the network resources and deploy the application workloads.

This guide follows the _common_ deployment option, described in more detail in the [Reference Architecture documentation](https://www.paloaltonetworks.com/resources/reference-architectures).

The common firewall option leverages a single set of VM-Series firewalls. The sole set of firewalls operates as a shared resource and may present scale limitations with all traffic flowing through a single set of firewalls due to the performance degradation that occurs when traffic crosses virtual routers. This option is suitable for proof-of-concepts and smaller scale deployments because the number of firewalls low. However, the technical integration complexity is high.

## Terraform

This guide introduces the Terraform code maintained within this repository, which will deploy the reference architecture described above.

## Topology

![gcp-common](https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/assets/6574404/acd1773a-f6c4-41a9-a307-031b46b70e88)

## Deploy the infrastructure

* The example.tfvars sets the VM-Series license to pay-as-you-go bundle2.  This means there is an additional charge on top of the compute running cost.  Please see <a href="https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/license-the-vm-series-firewall/vm-series-firewall-licensing">VM-Series licensing</a> for more information.
* If you do not want to deploy the spoke networks, delete the `spokes.tf` before applying the Terraform plan.

Below is the network topology of the build.  Everything  in the diagram is built with Terraform, including the local configuration of the compute resources.  All traffic to/from the spoke VPC networks flows through the VM-Series firewalls for inspection.  The VM-Series network interfaces are attached to the management, untrust, and trust networks.  All cloud workloads that are protected by the VM-Series are deployed in the spoke networks which are VPC peers with the trust network.

<p align="center">
    <img src="images/image1.png" width="500">
</p>
 
_Table 1. VPC Network Description_
<table>
  <tr>
   <td><strong>VPC Network</strong>
   </td>
   <td><strong>Purpose</strong>
   </td>
  </tr>
  <tr>
   <td>Management
   </td>
   <td>The VM-Series management interfaces are attached to this network.  The management interfaces are used to access the VM-Series user interface and/or SSH console.
   </td>
  </tr>
  <tr>
   <td>Untrust
   </td>
   <td>The VM-Series 1st dataplane interfaces (ethernet1/1) are attached to the untrust network.  Each untrust interface has an associated public IP address.  The public IP addresses are used to provide outbound internet access for spoke network resources.  
<p>
The untrust interface also serves as the backend of an external TCP/UDP load balancer.  The load balancer distributes internet inbound requests to the VM-Series untrust interfaces.  The VM-Series inspects and translates this traffic to the appropriate spoke address.
   </td>
  </tr>
  <tr>
   <td>Trust
   </td>
   <td>The trust network serves as the hub network and is VPC peers with the spoke networks.  The VM-Series trust dataplane interfaces (ethernet1/2) reside in the trust network and serve as the backend of an internal TCP/UDP load balancer.  
   </td>
  </tr>
  <tr>
   <td>Spoke1
   </td>
   <td>Spoke1 contains two web servers that are the backend of an internal TCP/UDP load balancer.  The network contains a custom default route to direct traffic to the VM-Series internal load balancer in the trust network.
   </td>
  </tr>
  <tr>
   <td>Spoke2 
   </td>
   <td>Spoke2 contains a single Ubuntu instance.  This instance is used to test internet outbound and east-west traffic.  The network contains a custom default route to direct traffic to the VM-Series internal load balancer in the trust network.
   </td>
  </tr>
</table>


## Build

1. Open Google cloud shell.

<p align="center">
    <img src="images/image2.png" width="500">
</p>

2. In cloud shell, copy and paste the following to enable the required APIs, create an SSH key, and to clone the Github repository.

```
gcloud services enable compute.googleapis.com
ssh-keygen -f ~/.ssh/gcp-demo -t rsa -C gcp-demo
git clone https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules
cd terraform-google-vmseries-modules/examples/hub_spoke_common
```

**If you are using a SSH key that is not `~/.ssh/gcp-demo`, you must modify the `public_key_path` value in the** `example.tfvars` **file.**

3.  Initialize and apply the Terraform plan.  

```
terraform init
terraform apply -var-file example.tfvars
```

4. Verify the apply output.  Enter `yes` to start the build.

5. When the build completes, the following output will be generated.

```
Apply complete! Resources: 69 added, 0 changed, 0 destroyed.

Outputs:

ext_lb_url = "http://x.x.x.x"
ssh_to_spoke2 = "ssh paloalto@x.x.x.x"
vmseries01_access = "https://x.x.x.x"
vmseries02_access = "https://x.x.x.x"
```


## Verify Build Completion 

1. The virtual machines can take an additional 10 minutes to finish their bootup process.  
  
2. Copy and paste the `VMSERIES01_ACCESS` and `VMSERIES02_ACCESS` output values into separate web browser tabs.

<p align="center">
    <img src="images/image5.png" width="500">
</p>

```
Username: paloalto
Password: Pal0Alt0@123
```

## Internet Inbound Traffic 
In this section, we will test internet inbound traffic to the web application hosted in spoke1.  The inbound request will be distributed by the external TCP/UDP load balancer to the VM-Series untrust interfaces.  The firewalls will inspect and translate the source address to the firewall's trust interface `192.168.2.x/24` and the destination address to the internal load balancer in spoke1 `10.1.0.10`.  

<p align="center"><i>Inbound: Client-to-Server Request</i></p>

<p align="center">
    <img src="images/image6.png" width="500">
</p>


<p align="center"><i>Inbound: Server-to-Client Response</i></p>

<p align="center">
    <img src="images/image7.png" width="500">
</p>


1. Copy and paste the `EXT_LB_URL` output value into a web browser.  This address is a frontend IP on the external load balancer.

<p align="center">
    <img src="images/image8.png" width="500">
</p>

2. The `SOURCE IP` and `LOCAL IP` display the VM-Series trust IP address and web VM IP address, respectively. Try refreshing the web page to test the load balancer's distribution. The `SOURCE IP` and `LOCAL IP` values will eventually change.

<p align="center">
    <img src="images/image9.png" width="500">
</p>

1. On both VM-Series, navigate to **Monitor → Traffic**.

<p align="center">
    <img src="images/image10.png" width="500">
</p>

4. Enter the following into the search bar to filter for the internet inbound traffic.

```
( zone.src eq untrust ) and ( zone.dst eq trust ) and ( app eq web-browsing )
```

<p align="center"><i>Traffic Logs: vmseries01</i></p>

<p align="center">
    <img src="images/image11.png" width="500">
</p>

<p align="center"><i>Traffic Logs: vmseries02</i></p>

<p align="center">
    <img src="images/image12.png" width="500">
</p>


## Internet Outbound Traffic

In this section, we will test internet outbound traffic from the spoke networks through the VM-Series firewalls.

<p align="center"><i>Outbound: Client-to-Server Request Path</i></p>

<p align="center">
    <img src="images/image13.png" width="500">
</p>

<p align="center"><i>Outbound: Client-to-Server Response Path</i></p>

<p align="center">
    <img src="images/image14.png" width="500">
</p>

1. Copy and paste the `SSH_TO_SPOKE2` output value into cloud shell.  The SSH address is a public IP associated with the external load balancer.

<p align="center">
    <img src="images/image15.png" width="500">
</p>

```
Password: Pal0Alt0@123
```

2. Try generating some outbound internet traffic by running the following commands from the spoke2-vm1 interface.

```
sudo apt update
sudo apt install traceroute
traceroute www.paloaltonetworks.com
```

1. On both VM-Series, go to **Monitor → Traffic**.

2. Enter the following into the search bar to filter for the outbound internet traffic.

```
( addr.src in 10.2.0.10 ) and ( app eq traceroute ) or ( app eq apt-get )
```

5. In this example, we can see that vmseries01 received the `apt-get` request and vmseries02 received the `traceroute` request.  This demonstrates the load balancing capability between the VM-Series firewall and the internal load balancer.

<p align="center"><i>Traffic Logs: vmseries01</i></p>

<p align="center">
    <img src="images/image16.png" width="500">
</p>

<p align="center"><i>Traffic Logs: vmseries02</i></p>

<p align="center">
    <img src="images/image17.png" width="500">
</p>



## East-West Traffic

Now, we will test east-west traffic between the spoke networks. The east-west traffic flow is similar to the internet outbound flow as described in the previous section.  However, instead of routing the spoke's request through the untrust interface, the VM-Series will hairpin the traffic through its trust interface.  Hairpinning east-west traffic provides a simplified design without sacrificing security capabilities. 

<p align="center"><i>East-West: Client-to-Server Request</i></p>

<p align="center">
    <img src="images/image18.png" width="500">
</p>

<p align="center"><i>East-West: Client-to-Server Response</i></p>

<p align="center">
    <img src="images/image19.png" width="500">
</p>


1. While logged into the spoke2-vm1, launch a repeat curl command to the web server’s internal load balancer in the spoke1. 

```
curl http://10.1.0.10/?[1-100]
```

2. On both VM-Series, go to **Monitor → Traffic**.

3. Enter the following into the search bar to filter for the east-west traffic.

```
( addr.src in 10.2.0.10 ) and ( addr.dst in 10.1.0.10 )
```

<p align="center"><i>Traffic Logs: vmseries01</i></p>

<p align="center">
    <img src="images/image21.png" width="500">
</p>


<p align="center"><i>Traffic Logs: vmseries02</i></p>

<p align="center">
    <img src="images/image22.png" width="500">
</p>


## Destroy Environment

When you are ready, destroy the environment by entering the following in cloud shell. 

```
cd terraform-google-vmseries-modules/examples/hub_spoke_common
terraform destroy -auto-approve -var-file example.tfvars
rm ~/.ssh/gcp-demo
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.3, < 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bootstrap"></a> [bootstrap](#module\_bootstrap) | ../../modules/bootstrap/ | n/a |
| <a name="module_iam_service_account"></a> [iam\_service\_account](#module\_iam\_service\_account) | ../../modules/iam_service_account/ | n/a |
| <a name="module_lb_external"></a> [lb\_external](#module\_lb\_external) | ../../modules/lb_external/ | n/a |
| <a name="module_lb_internal"></a> [lb\_internal](#module\_lb\_internal) | ../../modules/lb_internal/ | n/a |
| <a name="module_peering_trust_spoke1"></a> [peering\_trust\_spoke1](#module\_peering\_trust\_spoke1) | ../../modules/vpc-peering | n/a |
| <a name="module_peering_trust_spoke2"></a> [peering\_trust\_spoke2](#module\_peering\_trust\_spoke2) | ../../modules/vpc-peering | n/a |
| <a name="module_spoke1_ilb"></a> [spoke1\_ilb](#module\_spoke1\_ilb) | ../../modules/lb_internal/ | n/a |
| <a name="module_vmseries"></a> [vmseries](#module\_vmseries) | ../../modules/vmseries | n/a |
| <a name="module_vpc_mgmt"></a> [vpc\_mgmt](#module\_vpc\_mgmt) | terraform-google-modules/network/google | ~> 4.0 |
| <a name="module_vpc_spoke1"></a> [vpc\_spoke1](#module\_vpc\_spoke1) | terraform-google-modules/network/google | ~> 4.0 |
| <a name="module_vpc_spoke2"></a> [vpc\_spoke2](#module\_vpc\_spoke2) | terraform-google-modules/network/google | ~> 4.0 |
| <a name="module_vpc_trust"></a> [vpc\_trust](#module\_vpc\_trust) | terraform-google-modules/network/google | ~> 4.0 |
| <a name="module_vpc_untrust"></a> [vpc\_untrust](#module\_vpc\_untrust) | terraform-google-modules/network/google | ~> 4.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_instance.spoke1_vm](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_instance.spoke2_vm1](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_instance_group.spoke1_ig](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_group) | resource |
| [random_string.main](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [google_client_config.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_compute_zones.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_sources"></a> [allowed\_sources](#input\_allowed\_sources) | A list of IP addresses to be added to the management network's ingress firewall rule. The IP addresses will be able to access to the VM-Series management interface. | `list(string)` | `null` | no |
| <a name="input_cidr_mgmt"></a> [cidr\_mgmt](#input\_cidr\_mgmt) | The CIDR range of the management subnetwork. | `string` | `null` | no |
| <a name="input_cidr_spoke1"></a> [cidr\_spoke1](#input\_cidr\_spoke1) | The CIDR range of the management subnetwork. | `string` | `null` | no |
| <a name="input_cidr_spoke2"></a> [cidr\_spoke2](#input\_cidr\_spoke2) | The CIDR range of the spoke1 subnetwork. | `string` | `null` | no |
| <a name="input_cidr_trust"></a> [cidr\_trust](#input\_cidr\_trust) | The CIDR range of the trust subnetwork. | `string` | `null` | no |
| <a name="input_cidr_untrust"></a> [cidr\_untrust](#input\_cidr\_untrust) | The CIDR range of the untrust subnetwork. | `string` | `null` | no |
| <a name="input_fw_image_name"></a> [fw\_image\_name](#input\_fw\_image\_name) | The image name from which to boot an instance, including the license type and the version, e.g. vmseries-byol-814, vmseries-bundle1-814, vmseries-flex-bundle2-1001. Default is vmseries-flex-bundle1-913. | `string` | `"vmseries-flex-byol-1014"` | no |
| <a name="input_fw_machine_type"></a> [fw\_machine\_type](#input\_fw\_machine\_type) | The Google Cloud machine type for the VM-Series NGFW. | `string` | `"n1-standard-4"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Arbitrary string used to prefix resource names. | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID | `any` | `null` | no |
| <a name="input_public_key_path"></a> [public\_key\_path](#input\_public\_key\_path) | Local path to public SSH key.  If you do not have a public key, run >> ssh-keygen -f ~/.ssh/demo-key -t rsa -C admin | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Google Cloud region for the created resources. | `string` | `null` | no |
| <a name="input_spoke_vm_image"></a> [spoke\_vm\_image](#input\_spoke\_vm\_image) | The image path for the compute instances deployed in the spoke networks. | `string` | `"ubuntu-os-cloud/ubuntu-2004-lts"` | no |
| <a name="input_spoke_vm_scopes"></a> [spoke\_vm\_scopes](#input\_spoke\_vm\_scopes) | A list of service scopes. Both OAuth2 URLs and gcloud short names are supported. To allow full access to all Cloud APIs, use the cloud-platform | `list(string)` | <pre>[<br>  "https://www.googleapis.com/auth/cloud.useraccounts.readonly",<br>  "https://www.googleapis.com/auth/devstorage.read_only",<br>  "https://www.googleapis.com/auth/logging.write",<br>  "https://www.googleapis.com/auth/monitoring.write"<br>]</pre> | no |
| <a name="input_spoke_vm_type"></a> [spoke\_vm\_type](#input\_spoke\_vm\_type) | The GCP machine type for the compute instances in the spoke networks. | `string` | `"f1-micro"` | no |
| <a name="input_spoke_vm_user"></a> [spoke\_vm\_user](#input\_spoke\_vm\_user) | The username for the compute instance in the spoke networks. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ext_lb_url"></a> [ext\_lb\_url](#output\_ext\_lb\_url) | External load balancer's frontend URL that resolves to spoke1 web servers after VM-Series inspection. |
| <a name="output_ssh_to_spoke2"></a> [ssh\_to\_spoke2](#output\_ssh\_to\_spoke2) | External load balancer's frontend address that opens SSH session to spoke2-vm1 after VM-Series inspection. |
| <a name="output_vmseries01_access"></a> [vmseries01\_access](#output\_vmseries01\_access) | Management URL for vmseries01. |
| <a name="output_vmseries02_access"></a> [vmseries02\_access](#output\_vmseries02\_access) | Management URL for vmseries02. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
