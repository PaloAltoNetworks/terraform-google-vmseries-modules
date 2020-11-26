# IAM Service Account

Create a dedicated IAM Service Account that will be used to run firewall instances.
This module is optional - even if you don't use it, firewalls run fine on the default Google Service Account.

The account produced by this module is intended to have minimal required permissions.

[Google Cloud Docs](https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances#best_practices)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| google | ~> 3.30 |

## Providers

| Name | Version |
|------|---------|
| google | ~> 3.30 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| display\_name | n/a | `string` | `"Palo Alto Networks Firewall Service Account"` | no |
| roles | List of IAM role names, such as ["roles/compute.viewer"] or ["project/A/roles/B"]. The default list is suitable for Palo Alto Networks Firewall to run and publish custom metrics to GCP Stackdriver. | `set(string)` | <pre>[<br>  "roles/compute.networkViewer",<br>  "roles/logging.logWriter",<br>  "roles/monitoring.metricWriter",<br>  "roles/monitoring.viewer",<br>  "roles/viewer",<br>  "roles/stackdriver.accounts.viewer",<br>  "roles/stackdriver.resourceMetadata.writer"<br>]</pre> | no |
| service\_account\_id | n/a | `string` | `"The google_service_account.account_id of the created IAM account, unique string per project."` | no |

## Outputs

| Name | Description |
|------|-------------|
| email | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
