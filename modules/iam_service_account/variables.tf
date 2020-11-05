variable service_account_id {
  default = "The google_service_account.account_id of the created IAM account, unique string per project."
  type    = string
}

variable display_name {
  default = "Palo Alto Networks Firewall Service Account"
}

variable roles {
  description = "List of IAM role names, such as [\"roles/compute.viewer\"] or [\"project/A/roles/B\"]. The default list is suitable for Palo Alto Networks Firewall to run and publish custom metrics to GCP Stackdriver."
  default = [
    "roles/compute.networkViewer",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    # per https://docs.paloaltonetworks.com/vm-series/9-1/vm-series-deployment/set-up-the-vm-series-firewall-on-google-cloud-platform/deploy-vm-series-on-gcp/enable-google-stackdriver-monitoring-on-the-vm-series-firewall.html
    "roles/stackdriver.accounts.viewer",
    "roles/stackdriver.resourceMetadata.writer",
  ]
  type = set(string)
}
