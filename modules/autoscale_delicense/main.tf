# Create a log sink to match the delete of a VM from a Managed Instance group during the initial phase

resource "google_logging_project_sink" "this" {
  for_each               = var.cloud_functions
  destination            = "pubsub.googleapis.com/${google_pubsub_topic.this[each.key].id}"
  project                = each.value.project_id
  name                   = each.value.log_sink_name
  filter                 = var.log_sink_filter
  unique_writer_identity = true
}

# Create a pub/sub topic for messaging log sink events
resource "google_pubsub_topic" "this" {
  for_each = var.cloud_functions
  name     = each.value.topic_name
}

# Create a pub/sub subscription to pull messages from the topic
resource "google_pubsub_subscription" "this" {
  for_each                = var.cloud_functions
  name                    = each.value.subscription_name
  topic                   = google_pubsub_topic.this[each.key].name
  ack_deadline_seconds    = 10
  enable_message_ordering = false
}

# VPC Connector Required to access local Panorama instance

data "google_compute_network" "this" {
  for_each = var.cloud_functions
  name     = each.value.vpc_connector_network
}

resource "google_vpc_access_connector" "this" {
  for_each      = var.cloud_functions
  name          = each.value.vpc_connector_name
  project       = each.value.project_id
  region        = "${split("-", each.value.zone)[0]}-${split("-", each.value.zone)[1]}"
  ip_cidr_range = each.value.vpc_connector_cidr
  network       = data.google_compute_network.this[each.key].self_link
}

# CFN to find primary IP of deleted instance, lookup in panorama software license plugin if exists
# If primary IP matches a device in the plugin, it will deregister the firewall

resource "google_cloudfunctions_function" "this" {
  for_each              = var.cloud_functions
  name                  = each.key
  description           = try(each.value.description, null)
  runtime               = try(each.value.runtime, "python37")
  entry_point           = each.value.entry_point
  source_archive_bucket = each.value.bucket_name
  source_archive_object = google_storage_bucket_object.this.name
  #checkov:skip=CKV2_GCP_10:When using event trigger, HTTP Trigger is invalid and not used
  event_trigger {
    event_type = each.value.event_type
    resource   = google_pubsub_topic.this[each.key].id
  }
  available_memory_mb = try(each.value.available_memory_mb, 256)
  timeout             = try(each.value.timeout, 10)
  max_instances       = 20
  environment_variables = {
    "PROJECT_ID"  = each.value.project_id
    "ZONE"        = each.value.zone
    "PANORAMA_IP" = each.value.panorama_ip
    "SECRET_NAME" = each.value.secret_name
  }
  service_account_email         = google_service_account.this.email
  depends_on                    = [google_storage_bucket_object.this]
  vpc_connector                 = google_vpc_access_connector.this[each.key].self_link
  vpc_connector_egress_settings = "PRIVATE_RANGES_ONLY"
}

locals {
  source_dir    = "${path.module}/src"
  zip_file_name = "source_code.zip"
  zip_file_name_sha = "source_code.${lower(replace(data.archive_file.this.output_base64sha256, "=", ""))}.zip"
}

data "archive_file" "this" {
  type        = "zip"
  source_dir  = local.source_dir
  output_path = "/tmp/${local.zip_file_name}"
}

resource "google_storage_bucket_object" "this" {
  name   = local.zip_file_name_sha
  bucket = var.bucket_name
  source = "/tmp/${local.zip_file_name}"
}

resource "google_service_account" "this" {
  account_id   = var.cfn_identity_name
  display_name = var.cfn_identity_name
}

# Create a service account key Terraform Resource

#resource "google_service_account_key" "this" {
#  service_account_id = google_service_account.this.name
#  public_key_type    = "TYPE_X509_PEM_FILE"
#}

# Create a service account IAM bindings Terraform Resource

resource "google_project_iam_member" "sa_role" {
  for_each = toset(var.cfn_identity_roles)
  role     = each.key
  member   = "serviceAccount:${google_service_account.this.email}"
  project  = var.project_id
}


# Log router writer identity IAM
resource "google_pubsub_topic_iam_member" "pubsub_sink_member" {
  for_each = var.cloud_functions

  project = var.project_id
  topic   = each.value.topic_name
  role    = "roles/pubsub.publisher"
  member  = google_logging_project_sink.this[each.key].writer_identity
}
