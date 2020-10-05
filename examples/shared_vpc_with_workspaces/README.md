Shared VPC Design using Terraform Workspaces and environmental TFVARS


## Instruction

- Set up all the VPCs and Subnetworks prior to deploying (BROWNFIELD ONLY).
- Set up Panorama. This example assumes it exists with proper settings.
- Set the GCP Service Account with the sufficient permissions. The account will not only be used for GCP plugin access, but also for actually running the instances.
- Go to the main directory of the example (i.e. where this README.md is placed)
- Create Terraform Workspaces with naming convention: `<project prefix>-<environment type>-firewalls+<gcp region>`
- Put the created items into your `<environment>.tfvars`: (For multiple environment types please ensure the coincide with the environment name created in the workspace )
- Update `general.auto.tfvars` with 

```sh
terraform init
terraform workspace new <workspace name>
terraform init
terraform plan -var-file=<environment>.tfvars
terraform apply -var-file=<environment>.tfvars
```

## Requirements

| Name | Version |
|------|---------|
| terraform | ~>0.12 |
| google | ~> 3.35 |

## Providers

| Name | Version |
|------|---------|
| google | ~> 3.35 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| auth\_file | GCP Project auth JSON file | `string` | n/a | yes |
| develop\_locally | Go local development | `bool` | `false` | no |
| fw\_image | n/a | `string` | `"https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/vmseries"` | no |
| fw\_machine\_type | VM size, e.g. n1-standard-16 | `any` | n/a | yes |
| fw\_panos | VM-Series license and PAN-OS (ie: bundle1-814, bundle2-814, or byol-814) | `any` | n/a | yes |
| http\_basic\_auth | The result of `echo -n 'mynewuser:newpassword' | base64` which is known by the clients of the route-operator API server. | `string` | `"bXluZXd1c2VyOm5ld3Bhc3N3b3Jk"` | no |
| https\_cert\_pem\_file | Certificate (possibly self-signed) for the route-operator https API. The file can also contain a concatenated chain of certificates. | `string` | `"cert.pem"` | no |
| https\_interm\_pem\_file | The parent certificate that signed `https_cert_pem_file` certificate. The X509 field Subject should equal to the X509 field Issuer of `https_cert_pem_file`. | `string` | `"interm.pem"` | no |
| https\_key\_pem\_file | The private key file that corresponds to the first `https_cert_pem_file` certificate. | `string` | `"key.pem"` | no |
| outbound\_route\_dest | When creating outbound routes (i.e. routes from GCP to the Internet) what destination to use. For production environment set to 0.0.0.0/0 but it can be quite a pain during tests. | `string` | n/a | yes |
| prefix | Prefix to GCP resource names | `string` | n/a | yes |
| private\_key\_path | Local path to private SSH key. If you do not have a private key, run >> ssh-keygen -t rsa | `any` | n/a | yes |
| project\_id | GCP Project ID | `string` | n/a | yes |
| public\_key\_path | Local path to public SSH key. If you do not have a public key, run >> ssh-keygen -f ~/.ssh/demo-key -t rsa -C admin | `any` | n/a | yes |
| regions | n/a | `map` | `{}` | no |
| ro\_ilb\_name | n/a | `string` | `""` | no |
| ro\_ip\_address | The IP of the route-operator API. Points to an Internal Load Balancer. | `string` | `null` | no |
| subnetworks | Map of GCP Subnetworks | `map` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| fw\_interfaces | VM-Series Firewall Interface Output Details |
| info | Basic Known information output regarding region/environment/projectID |
| subnetworks | GCP Subnetwork Detailed Information Output |
