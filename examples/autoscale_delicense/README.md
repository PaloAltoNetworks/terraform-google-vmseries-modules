<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.9, < 2.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_us_central1_delicense"></a> [us\_central1\_delicense](#module\_us\_central1\_delicense) | ../../modules/autoscale_deliense | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The Google Cloud Storage bucket to store the CFN package | `string` | `""` | no |
| <a name="input_cfn_identity_name"></a> [cfn\_identity\_name](#input\_cfn\_identity\_name) | Name of the Cloud Function Service Account | `string` | `"autoscale-identity"` | no |
| <a name="input_cfn_identity_roles"></a> [cfn\_identity\_roles](#input\_cfn\_identity\_roles) | Roles to be applied to the service account identity for the cloud function | `list(any)` | `[]` | no |
| <a name="input_cloud_functions"></a> [cloud\_functions](#input\_cloud\_functions) | Map of the Cloud Functions you want to deploy | `map(any)` | `{}` | no |
| <a name="input_project"></a> [project](#input\_project) | The project name to deploy the infrastructure in to. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | The region into which to deploy the infrastructure in to | `string` | `"us-central1"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->