resource "google_compute_instance_template" "this" {
  name_prefix      = var.prefix
  machine_type     = var.machine_type
  min_cpu_platform = var.min_cpu_platform
  can_ip_forward   = true
  tags             = var.tags
  metadata         = var.metadata

  service_account {
    scopes = var.scopes
    email  = var.service_account_email
  }

  // Create multiple interfaces (max 8)
  dynamic "network_interface" {
    for_each = var.network_interfaces

    content {
      subnetwork = network_interface.value.subnetwork

      dynamic "access_config" {
        for_each = try(network_interface.value.create_public_ip, false) ? ["one"] : []
        content {}
      }
    }
  }

  disk {
    source_image = var.image
    disk_type    = var.disk_type
    auto_delete  = true
    boot         = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_group_manager" "this" {
  for_each = var.zones

  base_instance_name = "${var.prefix}-fw"
  name               = "${var.prefix}-igm-${each.value}"
  zone               = each.value
  target_pools       = compact([var.pool])

  version {
    instance_template = google_compute_instance_template.this.id
  }

  lifecycle {
    # Ignore the name changes and only react to the version.instance_template changes.
    # Google webui uses dummy name changes to implement Rolling Restart.
    ignore_changes = [
      version[0].name,
      version[1].name,
    ]
  }

  update_policy {
    type = var.update_policy_type
    // Currently in google-beta provider.  Will merge when it becomes GA.
    #min_ready_sec   = var.update_policy_min_ready_sec
    max_surge_fixed = 1
    minimal_action  = "REPLACE"
  }

  dynamic "named_port" {
    for_each = var.named_ports
    content {
      name = named_port.value.name
      port = named_port.value.port
    }
  }
}

resource "random_id" "autoscaler" {
  for_each = var.zones
  keepers = {
    # Re-randomize on igm change. It forcibly recreates all users of this random_id.
    google_compute_instance_group_manager = try(google_compute_instance_group_manager.this[each.key].id, null)
  }
  byte_length = 3
}

resource "google_compute_autoscaler" "this" {
  for_each = var.zones
  name     = "${var.prefix}-${random_id.autoscaler[each.key].hex}-as-${each.value}"
  target   = try(google_compute_instance_group_manager.this[each.key].id, "")
  zone     = each.value

  autoscaling_policy {
    max_replicas    = var.max_replicas_per_zone
    min_replicas    = var.min_replicas_per_zone
    cooldown_period = var.cooldown_period

    # cpu_utilization { target = 0.7 }

    dynamic "metric" {
      for_each = var.autoscaler_metrics
      content {
        name   = metric.key
        type   = try(metric.value.type, "GAUGE")
        target = metric.value.target
      }
    }

    scale_in_control {
      time_window_sec = var.scale_in_control_time_window_sec
      max_scaled_in_replicas {
        fixed = var.scale_in_control_replicas_fixed
      }
    }
  }
}

#---------------------------------------------------------------------------------
# Pub-Sub is intended to be used by various cloud applications to register
# new ip/port that would be consumed by Panorama and automatically onboarded.

resource "google_pubsub_topic" "this" {
  name = "${var.deployment_name}-panorama-apps-deployment"
}

resource "google_pubsub_subscription" "this" {
  name  = "${var.deployment_name}-panorama-plugin-subscription"
  topic = google_pubsub_topic.this.id
}

resource "google_pubsub_subscription_iam_member" "this" {
  subscription = google_pubsub_subscription.this.id
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${coalesce(var.service_account_email, data.google_compute_default_service_account.this.email)}"
}

data "google_compute_default_service_account" "this" {}

#---------------------------------------------------------------------------------
# The following resources are used for delicensing

resource "random_id" "postfix" {
  byte_length = 2
}

locals {
  delicensing_cfn = {
    panorama_ip             = var.panorama_ip
    bucket_name             = "${var.prefix}-${local.cfn_name}-${random_id.postfix.hex}"
    source_dir              = "${path.module}/src"
    zip_file_name           = "delicensing_cfn.zip"
    zip_file_name_sha       = "delicensing_cfn.${lower(replace(data.archive_file.delicensing_cfn.output_base64sha256, "=", ""))}.zip"
    runtime_sa_account_id   = "${var.prefix}${var.delicensing_cfn_name}-sa-${random_id.postfix.hex}"
    runtime_sa_display_name = "Delicensing Cloud Function runtime SA"
    runtime_sa_roles = [
      # "roles/iam.serviceAccountUser",
      "roles/secretmanager.secretAccessor",
      "roles/compute.viewer",
    ]
    topic_name         = "${var.prefix}${var.delicensing_cfn_name}_topic-${random_id.postfix.hex}"
    log_sink_name      = "${var.prefix}${var.delicensing_cfn_name}_logsink-${random_id.postfix.hex}"
    entry_point        = "autoscale_delete_event"
    description        = "Cloud Function to delicense firewalls in Panorama on scale-in events"
    subscription_name  = "${var.prefix}${var.delicensing_cfn_name}_subscription"
    secret_name        = "${var.prefix}${var.delicensing_cfn_name}_pano_creds-${random_id.postfix.hex}"
    vpc_connector_name = "${var.prefix}${var.delicensing_cfn_name}-vpc-connector-${random_id.postfix.hex}"
  }
}

# Secret to store Panorama credentials.
# Credentials itself are set manually.
resource "google_secret_manager_secret" "delicensing_cfn_pano_creds" {
  count     = var.enable_delicensing ? 1 : 0
  secret_id = local.delicensing_cfn.secret_name
}

# Create a log sink to match the delete of a VM from a Managed Instance group during the initial phase
resource "google_logging_project_sink" "delicensing_cfn" {
  count = var.enable_delicensing ? 1 : 0

  destination            = "pubsub.googleapis.com/${google_pubsub_topic.this[0].id}"
  name                   = local.delicensing_cfn.log_sink_name
  filter                 = local.delicensing_cfn.log_sink_filter
  unique_writer_identity = true
}

# Create a pub/sub topic for messaging log sink events
resource "google_pubsub_topic" "delicensing_cfn" {
  count = var.enable_delicensing ? 1 : 0
  name  = local.delicensing_cfn.topic_name
}

# Create a pub/sub subscription to pull messages from the topic
resource "google_pubsub_subscription" "delicensing_cfn" {
  count                   = var.enable_delicensing ? 1 : 0
  name                    = local.delicensing_cfn.subscription_name
  topic                   = google_pubsub_topic.delicensing[0].name
  ack_deadline_seconds    = 10
  enable_message_ordering = false
}

# VPC Connector required to access local Panorama instance
data "google_compute_network" "panorama_network" {
  count = var.enable_delicensing ? 1 : 0
  name  = var.vpc_connector_network
}

resource "google_vpc_access_connector" "delicensing_cfn" {
  count         = var.enable_delicensing ? 1 : 0
  name          = local.delicensing_cfn.vpc_connector_name
  region        = var.region
  ip_cidr_range = var.vpc_connector_cidr
  network       = data.google_compute_network.panorama_network[0].self_link
}

data "google_project" "project" {
}

resource "google_cloudfunctions_function" "delicensing_cfn" {
  count                 = var.enable_delicensing ? 1 : 0
  name                  = var.delicensing_cfn_name
  description           = local.delicensing_cfn.description
  runtime               = "python310"
  entry_point           = local.delicensing_cfn.entry_point
  source_archive_bucket = google_storage_bucket.delicensing_cfn.self_link
  source_archive_object = google_storage_bucket_object.delicensing_cfn.self_link
  #checkov:skip=CKV2_GCP_10:When using event trigger, HTTP Trigger is invalid and not used
  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.delicensing_cfn[0].id
  }
  available_memory_mb = 256
  timeout             = 60
  max_instances       = 20
  environment_variables = {
    "PANORAMA_IP" = var.panorama_ip
    "SECRET_NAME" = google_secret_manager_secret.delicensing_cfn_pano_creds.secret_id
  }
  service_account_email         = google_service_account.delicensing_cfn.email
  depends_on                    = [google_storage_bucket_object.delicensing_cfn]
  vpc_connector                 = google_vpc_access_connector.delicensing_cfn[0].self_link
  vpc_connector_egress_settings = "PRIVATE_RANGES_ONLY"
}

# CFN bucket
resource "google_storage_bucket" "delicensing_cfn" {
  count         = var.enable_delicensing ? 1 : 0
  name          = local.delicensing_cfn.bucket_name
  location      = var.delicensing_cfn_bucket_location
  force_destroy = true

  public_access_prevention = "enforced"
}

data "archive_file" "delicensing_cfn" {
  count       = var.enable_delicensing ? 1 : 0
  type        = "zip"
  source_dir  = local.delicensing_cfn.source_dir
  output_path = "/tmp/${local.delicensing_cfn.zip_file_name}"
}

resource "google_storage_bucket_object" "delicensing_cfn" {
  count  = var.enable_delicensing ? 1 : 0
  name   = local.delicensing_cfn.zip_file_name_sha
  bucket = local.delicensing_cfn.bucket_name
  source = "/tmp/${local.delicensing_cfn.zip_file_name}"
}

# CFN Service Account
resource "google_service_account" "delicensing_cfn" {
  count        = var.enable_delicensing ? 1 : 0
  account_id   = local.delicensing_cfn.cfn_identity_account_id
  display_name = local.delicensing_cfn.cfn_identity_display_name
}

resource "google_project_iam_member" "delicensing_cfn" {
  for_each = var.enable_delicensing ? toset(local.delicensing_cfn.runtime_sa_roles) : []
  role     = each.key
  member   = "serviceAccount:${google_service_account.delicensing_cfn.email}"
}

# Allow log router writer to write to pub/sub
resource "google_pubsub_topic_iam_member" "pubsub_sink_member" {
  count  = var.enable_delicensing ? 1 : 0
  topic  = local.delicensing_cfn.topic_name
  role   = "roles/pubsub.publisher"
  member = google_logging_project_sink.delicensing_cfn[0].writer_identity
}