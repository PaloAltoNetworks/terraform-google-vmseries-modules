variable bucket_name {
}

variable file_location {
}

variable config {
  type    = list(string)
  default = []
}

variable content {
  type    = list(string)
  default = []
}

variable license {
  type    = list(string)
  default = []
}

variable software {
  default = []
}

variable service_account {
  description = "Optional IAM Service Account (just an email) that will be granted read-only access to this bucket"
  default     = null
  type        = string
}
