resource "google_service_account" "this" {
  account_id   = var.service_account_id
  display_name = var.display_name
}

resource "google_project_iam_member" "logging_logWriter" {
  role   = "roles/logging.logWriter"
  member = "serviceAccount:${google_service_account.this.email}"
}

resource "google_project_iam_member" "monitoring_metricWriter" {
  role   = "roles/monitoring.metricWriter"
  member = "serviceAccount:${google_service_account.this.email}"
}

resource "google_project_iam_member" "monitoring_viewer" {
  role   = "roles/monitoring.viewer"
  member = "serviceAccount:${google_service_account.this.email}"
}

resource "google_project_iam_member" "stackdriver_resourceMetadata_writer" {
  role   = "roles/stackdriver.resourceMetadata.writer"
  member = "serviceAccount:${google_service_account.this.email}"
}

# per https://docs.paloaltonetworks.com/vm-series/9-1/vm-series-deployment/set-up-the-vm-series-firewall-on-google-cloud-platform/deploy-vm-series-on-gcp/enable-google-stackdriver-monitoring-on-the-vm-series-firewall.html
resource "google_project_iam_member" "stackdriver_accounts_viewer" {
  role   = "roles/stackdriver.accounts.viewer"
  member = "serviceAccount:${google_service_account.this.email}"
}
