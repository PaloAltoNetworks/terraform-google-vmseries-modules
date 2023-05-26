variable "project_id" {
  default = ""
}

variable "bucket_name" {
  description = "The Google Cloud Storage bucket to store the CFN package"
  default     = ""
}

variable "cloud_functions" {
  description = "Map of the Cloud Functions you want to deploy"
  type        = map(any)
  default     = {}
}

variable "log_sink_filter" {
  description = "Filter to look for Managed Instance Group deletions"
  default     = "protoPayload.requestMetadata.callerSuppliedUserAgent=\"GCE Managed Instance Group\" AND protoPayload.methodName=\"v1.compute.instances.delete\" AND protoPayload.response.progress=\"0\""
}

variable "cfn_identity_roles" {
  description = "Roles to be applied to the service account identity for the cloud function"
  type        = list(any)
  default     = []
}

variable "cfn_identity_name" {
  description = "Name of the Cloud Function Service Account"
  type        = string
  default     = "autoscale-identity"
}