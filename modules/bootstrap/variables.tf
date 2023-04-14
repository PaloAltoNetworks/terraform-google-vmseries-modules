variable "name_prefix" {
  description = "Prefix of the name of Google Cloud Storage bucket, followed by 10 random characters"
  default     = "paloaltonetworks-firewall-bootstrap-"
  type        = string
}

variable "files" {
  description = "Map of all files to copy to bucket. The keys are local paths, the values are remote paths. For example `{\"dir/my.txt\" = \"config/init-cfg.txt\"}`"
  default     = {}
  type        = map(string)
}

variable "service_account" {
  description = "Optional IAM Service Account (just an email) that will be granted read-only access to this bucket"
  default     = null
  type        = string
}

variable "location" {
  description = "Location in which the GCS Bucket will be deployed. Available locations can be found under https://cloud.google.com/storage/docs/locations."
  type        = string
}


variable "folders" {
  description = <<-EOF
  A list of folder paths that will impact where the bootstrap package(s) folders will be created in.
  A default value (empty list) will cause the bootstrap package folders to be created in the bucket root directory.
  EOF
  default     = []
  type        = list(any)
}