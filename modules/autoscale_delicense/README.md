<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2, < 2.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [google_cloudfunctions_function.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions_function) | resource |
| [google_logging_project_sink.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_project_sink) | resource |
| [google_project_iam_member.sa_role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_pubsub_subscription.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription) | resource |
| [google_pubsub_topic.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_pubsub_topic_iam_member.pubsub_sink_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam_member) | resource |
| [google_service_account.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_storage_bucket_object.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |
| [google_vpc_access_connector.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/vpc_access_connector) | resource |
| [archive_file.this](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [google_compute_network.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_network) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The Google Cloud Storage bucket to store the CFN package | `string` | `""` | no |
| <a name="input_cfn_identity_name"></a> [cfn\_identity\_name](#input\_cfn\_identity\_name) | Name of the Cloud Function Service Account | `string` | `"autoscale-identity"` | no |
| <a name="input_cfn_identity_roles"></a> [cfn\_identity\_roles](#input\_cfn\_identity\_roles) | Roles to be applied to the service account identity for the cloud function | `list(any)` | `[]` | no |
| <a name="input_cloud_functions"></a> [cloud\_functions](#input\_cloud\_functions) | Map of the Cloud Functions you want to deploy | `map(any)` | `{}` | no |
| <a name="input_log_sink_filter"></a> [log\_sink\_filter](#input\_log\_sink\_filter) | Filter to look for Managed Instance Group deletions | `string` | `"protoPayload.requestMetadata.callerSuppliedUserAgent=\"GCE Managed Instance Group\" AND protoPayload.methodName=\"v1.compute.instances.delete\" AND protoPayload.response.progress=\"0\""` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | `""` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_cfn_details"></a> [cfn\_details](#output\_cfn\_details) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->