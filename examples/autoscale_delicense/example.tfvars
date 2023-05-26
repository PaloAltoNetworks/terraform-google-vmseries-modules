bucket_name = "cfn_bucket_name"
project     = "<project id>"
region      = "<region to deploy CFN>"
cfn_identity_roles = [
  "roles/iam.serviceAccountUser",
  "roles/secretmanager.secretAccessor",
  "roles/compute.viewer",
  "roles/iam.serviceAccountUser"
]
cfn_identity_name = "autoscale-identity"
cloud_functions = {
  cf_autoscale_2 = {
    project_id            = "<project id>"
    zone                  = "us-central1-a"
    igm_name              = "<instance group manager name>"
    panorama_ip           = "<PANORAMA IP>"
    bucket_name           = "cfn_bucket_name"
    event_type            = "google.pubsub.topic.publish"
    topic_name            = "autoscale_delete_topic"
    log_sink_name         = "autoscale_delete_logsink"
    entry_point           = "autoscale_delete_event"
    description           = "Cloud Function to inspect instances and autoscale sizes to delicense firewalls in panorama"
    runtime               = "python310"
    available_memory_mb   = 256
    timeout               = 60
    subscription_name     = "autoscale_delete_subscription"
    lm                    = "<panorama license manager name>"
    secret_name           = "<panorama_secret_key_name>"
    vpc_connector_network = "<vpc network name for connector>"
    vpc_connector_name    = "autoscale-cfn-connector"
    vpc_connector_cidr    = "10.254.190.64/28"
  }
}