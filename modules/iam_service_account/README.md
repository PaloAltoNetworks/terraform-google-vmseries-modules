# IAM Service Account

Create a dedicated IAM Service Account that will be used to run firewall instances.
This module is optional - even if you don't use it, firewalls run fine on the default Google Service Account.

The account produced by this module is intended to have minimal required permissions.

[Google Cloud Docs](https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances#best_practices)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

The following requirements are needed by this module:

- google (~> 3.30)

## Required Inputs

No required input.

## Optional Inputs

The following input variables are optional (have default values):

### display\_name

Description: n/a

Type: `string`

Default: `"Palo Alto Networks Firewall Service Account"`

### roles

Description: List of IAM role names, such as ["roles/compute.viewer"] or ["project/A/roles/B"]. The default list is suitable for Palo Alto Networks Firewall to run and publish custom metrics to GCP Stackdriver.

Type: `set(string)`

Default:

```json
[
  "roles/compute.networkViewer",
  "roles/logging.logWriter",
  "roles/monitoring.metricWriter",
  "roles/monitoring.viewer",
  "roles/viewer",
  "roles/stackdriver.accounts.viewer",
  "roles/stackdriver.resourceMetadata.writer"
]
```

### service\_account\_id

Description: n/a

Type: `string`

Default: `"The google_service_account.account_id of the created IAM account, unique string per project."`

## Outputs

The following outputs are exported:

### email

Description: n/a

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
