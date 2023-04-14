locals {
  bootstrap_filenames = { for f in fileset(var.bootstrap_files, "**") : "${var.bootstrap_files}/${f}" => f }
  filenames = merge(local.bootstrap_filenames, var.files)
}
resource "random_string" "randomstring" {
  length    = 10
  min_lower = 10
  special   = false
}

resource "google_storage_bucket" "this" {
  name                        = join("", [var.name_prefix, random_string.randomstring.result])
  force_destroy               = true
  uniform_bucket_level_access = true
  location                    = var.location

  versioning {
    enabled = true
  }
}

output "bootstrap_bucket_files" {
  value = local.bootstrap_filenames
}

resource "google_storage_bucket_object" "file" {
  for_each = local.filenames

  name   = each.value
  source = each.key
  bucket = google_storage_bucket.this.name
}

resource "google_storage_bucket_object" "config_empty" {
  count = contains([for f in values(var.files) : true if trimprefix(f, "config/") != f], true) ? 0 : 1

  name    = "config/"
  content = "config/"
  bucket  = google_storage_bucket.this.name
}

resource "google_storage_bucket_object" "content_empty" {
  count = contains([for f in values(var.files) : true if trimprefix(f, "content/") != f], true) ? 0 : 1

  name    = "content/"
  content = "content/"
  bucket  = google_storage_bucket.this.name
}

resource "google_storage_bucket_object" "license_empty" {
  count = contains([for f in values(var.files) : true if trimprefix(f, "license/") != f], true) ? 0 : 1

  name    = "license/"
  content = "license/"
  bucket  = google_storage_bucket.this.name
}

resource "google_storage_bucket_object" "software_empty" {
  count = contains([for f in values(var.files) : true if trimprefix(f, "software/") != f], true) ? 0 : 1

  name    = "software/"
  content = "software/"
  bucket  = google_storage_bucket.this.name
}

data "google_compute_default_service_account" "this" {}

resource "google_storage_bucket_iam_member" "member" {
  bucket = google_storage_bucket.this.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${var.service_account != null ? var.service_account : data.google_compute_default_service_account.this.email}"
}
