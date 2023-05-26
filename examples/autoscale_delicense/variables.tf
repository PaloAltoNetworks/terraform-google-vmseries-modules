variable "project" {
  description = "The project name to deploy the infrastructure in to."
  type        = string
  default     = null
}
variable "region" {
  description = "The region into which to deploy the infrastructure in to"
  type        = string
  default     = "us-central1"
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