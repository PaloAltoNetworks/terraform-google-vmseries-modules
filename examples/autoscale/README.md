# Deployment of Palo Alto Networks VM-Series Firewalls with Autoscaling

The firewalls are created and destroyed by the GCP managed instance group.

For enhanced security, the firewalls' management interfaces are unreachable through public IP addresses (there is however a jumphost to aid initial troubleshooting).

## Caveat

1. The auto-scaling happens independently in each zone (it appears to be a limitation of GCP plugin 2.0.0 on Panorama, it simply does not check for the regional instance groups). The test was on Panorama 9.1.4.
2. The PanOS custom GCP metrics like `panSessionActive` require more work. See the GCP Metric Explorer.

## Instruction

- Set up Panorama and its VPC (consider using `examples/panorama`).
- Configure Panorama. This example assumes it exists with proper settings.
- Optionally, restart Panorama with `request restart system` to ensure the vm-auth-key is saved properly.
- Go to the main directory of the example (i.e. where this `README.md` is placed).
- Copy the `example.tfvars` into `terraform.tfvars` and modify it to your needs.
- Generate the SSH keys in the example's directory e.g.: `ssh-keygen -t rsa -C admin -N '' -f id_rsa`
- Manually edit the settings in `bootstrap_files/authcodes`
- Manually edit the settings in `bootstrap_files/init-cfg.txt`
- Deploy Terraform:

```sh
terraform init
terraform plan
terraform apply
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

The following requirements are needed by this module:

- terraform (>= 0.12, < 0.13)

- google (= 3.48)

## Required Inputs

The following input variables are required:

### intlb\_network

Description: Name of the defined network that will host the Internal Load Balancer. One of the names from the `networks[*].name` attribute.

Type: `any`

### mgmt\_network

Description: Name of the network to create for firewall management. One of the names from the `networks[*].name` attribute.

Type: `any`

### networks

Description: The list of maps describing the VPC networks and subnetworks

Type: `any`

## Optional Inputs

The following input variables are optional (have default values):

### autoscaler\_metrics

Description: The map with the keys being metrics identifiers (e.g. custom.googleapis.com/VMSeries/panSessionUtilization).  
Each of the contained objects has attribute `target` which is a numerical threshold for a scale-out or a scale-in.  
Each zonal group grows until it satisfies all the targets.

Additional optional attribute `type` defines the metric as either `GAUGE` (the default), `DELTA_PER_SECOND`, or `DELTA_PER_MINUTE`.  
For full specification, see the `metric` inside the [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_autoscaler).

Type: `map`

Default:

```json
{
  "custom.googleapis.com/VMSeries/panSessionActive": {
    "target": 100
  }
}
```

### extlb\_healthcheck\_port

Description: n/a

Type: `number`

Default: `80`

### extlb\_name

Description: n/a

Type: `string`

Default: `"as4-fw-extlb"`

### fw\_image\_uri

Description: Link to VM-Series PAN-OS image. Can be either a full self\_link, or one of the shortened forms per the [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#image).

Type: `string`

Default: `"https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/vmseries-byol-912"`

### fw\_machine\_type

Description: n/a

Type: `string`

Default: `"n1-standard-4"`

### fw\_network\_ordering

Description: A list of names from the `networks[*].name` attributes.

Type: `list`

Default: `[]`

### intlb\_global\_access

Description: (Optional) If true, clients can access ILB from all regions. By default false, only allow from the ILB's local region; useful if the ILB is a next hop of a route.

Type: `bool`

Default: `false`

### intlb\_name

Description: n/a

Type: `string`

Default: `"as4-fw-intlb"`

### mgmt\_sources

Description: n/a

Type: `list(string)`

Default:

```json
[
  "0.0.0.0/0"
]
```

### prefix

Description: Prefix to GCP resource names, an arbitrary string

Type: `string`

Default: `"as4"`

### private\_key\_path

Description: Local path to private SSH key. To generate the key pair use `ssh-keygen -t rsa -C admin -N '' -f id_rsa`

Type: `any`

Default: `null`

### public\_key\_path

Description: Local path to public SSH key. To generate the key pair use `ssh-keygen -t rsa -C admin -N '' -f id_rsa`  If you do not have a public key, run `ssh-keygen -f ~/.ssh/demo-key -t rsa -C admin`

Type: `string`

Default: `"id_rsa.pub"`

### service\_account

Description: IAM Service Account for running firewall instances (just the identifier, without `@domain` part)

Type: `string`

Default: `"paloaltonetworks-fw"`

## Outputs

The following outputs are exported:

### jumphost\_ssh\_command

Description: n/a

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
