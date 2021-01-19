# Regional Terraform Workspaces Example

## Description

A multi-region and multi-environment deployment, where the region is geographical and environment means dev, qa, prod, etc.

Every region, and every environment in it, uses:

- a separate Terraform Workspace (In other words it has a separate Terraform state.)
- a separate variable file,
- but, crucially, the same Terraform code.

## Instruction

### Brownfield

Here, brownfield are the VPC networks and subnetworks that are already existant
before our main deployment of this example runs. These resources
come from outside, e.g. from some native deployment manager or manual ui work.

We have a minimal Terraform code that creates the brownfield VPCs, and the main code of this example "pretends"
that these were already existent.

- Set up the simulation of the brownfield:

```sh
cd brownfield
terraform init
terraform apply
cd -
```

### Main Deployment

- Set up Panorama. This example assumes it exists with proper settings.
- Set the GCP Service Account with the sufficient permissions. The account will not only be used for GCP plugin access, but also for actually running the instances.
- Go to the main directory of the example (i.e. where this README.md is placed)
- Create Terraform Workspaces with naming convention: `<myprefix>-<environment>-firewalls+<region>`
- Put the created items into your `<environment>.tfvars`: (For multiple environment types please ensure the coincide with the environment name created in the workspace )
- Update `general.auto.tfvars` with variables that are intended to be identical in all environments
- Run commands:

```sh
terraform init
terraform workspace new '<myprefix>-<environment>-firewalls+<region>'
terraform workspace select '<myprefix>-<environment>-firewalls+<region>'
terraform init
terraform plan -var-file=<environment>.tfvars
terraform apply -var-file=<environment>.tfvars
```

## Common errors

### Invalid index

```txt
Error: Invalid index

  on main.tf line ...
    |----------------
    | local.region is "default"
    | var.regions is object with 1 attribute "us-central1"
```

The reason is wrong workspace, indicated by `*` below:

```sh
$ terraform workspace list
* default
  example-another
  example-nonprod-firewalls+us-central1
```

Apply the main instruction again to correct the situation:

```sh
$ terraform workspace new 'example-nonprod-firewalls+us-central1'
Workspace "example-nonprod-firewalls+us-central1" already exists
$ terraform workspace select 'example-nonprod-firewalls+us-central1'
$ terraform workspace list
  default
  example-another
* example-nonprod-firewalls+us-central1
```

Make sure that the workspace name marked `*` is suffixed with `+us-central1` or similar. It needs
to be a plus sign `+` followed by a valid Google Cloud Region name, and the region needs to be
referenced in your variable `regions`. In this example, the code would expect `regions["us-central1"]`
to be defined by you.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

The following requirements are needed by this module:

- terraform (~>0.12)

- google (= 3.48)

## Required Inputs

The following input variables are required:

### auth\_file

Description: GCP Project auth JSON file

Type: `string`

### outbound\_route\_dest

Description: When creating outbound routes (i.e. routes from GCP to the Internet) what destination to use. For production environment set to 0.0.0.0/0 but it can be quite a pain during tests.

Type: `string`

### prefix

Description: Prefix to GCP resource names

Type: `string`

### project\_id

Description: GCP Project ID

Type: `string`

### regions

Description: n/a

Type: `any`

## Optional Inputs

The following input variables are optional (have default values):

### develop\_locally

Description: Go local development

Type: `bool`

Default: `false`

### fw\_machine\_type

Description: VM size, e.g. n1-standard-16

Type: `any`

Default: `null`

### http\_basic\_auth

Description: The result of `echo -n 'mynewuser:newpassword' | base64` which is known by the clients of the route-operator API server.

Type: `string`

Default: `"bXluZXd1c2VyOm5ld3Bhc3N3b3Jk"`

### https\_cert\_pem\_file

Description: Certificate (possibly self-signed) for the route-operator https API. The file can also contain a concatenated chain of certificates.

Type: `string`

Default: `"cert.pem"`

### https\_interm\_pem\_file

Description: The parent certificate that signed `https_cert_pem_file` certificate. The X509 field Subject should equal to the X509 field Issuer of `https_cert_pem_file`.

Type: `string`

Default: `"interm.pem"`

### https\_key\_pem\_file

Description: The private key file that corresponds to the first `https_cert_pem_file` certificate.

Type: `string`

Default: `"key.pem"`

### panos\_image\_name

Description: VM-Series license and PAN-OS (ie: vmseries-bundle1-912, vmseries-byol-814, etc)

Type: `string`

Default: `"vmseries-flex-byol-913"`

### public\_key\_path

Description: Local path to public SSH key. If you do not have a public key, run >> ssh-keygen -f ~/.ssh/demo-key -t rsa -C admin

Type: `string`

Default: `"~/.ssh/id_rsa.pub"`

### ro\_ilb\_name

Description: n/a

Type: `string`

Default: `""`

### ro\_ip\_address

Description: The IP of the route-operator API. Points to an Internal Load Balancer.

Type: `string`

Default: `null`

## Outputs

The following outputs are exported:

### info

Description: Basic Known information output regarding region/environment/projectID

### management\_addresses

Description: VM-Series Firewall Management Addresses

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
