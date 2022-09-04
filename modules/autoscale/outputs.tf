output "zone_instance_group_id" {
  description = "The resource ID of the zone-based VM-Series managed instance group.  This output should only be used when `use_regional_mig` is set to `false`."
  value       = var.use_regional_mig ? null : { for k, v in google_compute_instance_group_manager.zonal : k => v.instance_group }
}

output "regional_instance_group_id" {
  description = "The resource ID of the regional VM-Series managed instance group.  This output should only be used when `use_regional_mig` is set to `true`."
  value       = var.use_regional_mig ? google_compute_region_instance_group_manager.regional[0].instance_group : null
}

output "pubsub_topic_id" {
  description = "The resource ID of the Pub/Sub Topic."
  value       = var.create_pubsub_topic ? google_pubsub_topic.main[0].id : null
}

output "pubsub_subscription_id" {
  description = "The resource ID of the Pub/Sub Subscription."
  value       = var.create_pubsub_topic ? google_pubsub_subscription.main[0].id : null
}

output "pubsub_subscription_iam_member_etag" {
  description = "The etag of the Pub/Sub IAM Member."
  value       = var.create_pubsub_topic ? google_pubsub_subscription_iam_member.main[0].etag : null
}