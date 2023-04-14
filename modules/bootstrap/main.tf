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

locals {
  folders = length(var.folders) == 0 ? [""] : var.folders
}


resource "google_storage_bucket_object" "config_empty" {
  for_each = toset(local.folders)

  name    = each.value != "" ? "${each.value}/config/" : "config/"
  content = "config/"
  bucket  = google_storage_bucket.this.name
}

resource "google_storage_bucket_object" "content_empty" {
  for_each = toset(local.folders)

  name    = each.value != "" ? "${each.value}/content/" : "content/"
  content = "content/"
  bucket  = google_storage_bucket.this.name
}

resource "google_storage_bucket_object" "license_empty" {
  for_each = toset(local.folders)

  name    = each.value != "" ? "${each.value}/license/" : "license/"
  content = "license/"
  bucket  = google_storage_bucket.this.name
}

resource "google_storage_bucket_object" "software_empty" {
  for_each = toset(local.folders)

  name    = each.value != "" ? "${each.value}/software/" : "software/"
  content = "software/"
  bucket  = google_storage_bucket.this.name
}

resource "google_storage_bucket_object" "file" {
  for_each = var.files

  name   = each.value
  source = each.key
  bucket = google_storage_bucket.this.name
}

data "google_compute_default_service_account" "this" {}

resource "google_storage_bucket_iam_member" "member" {
  bucket = google_storage_bucket.this.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${var.service_account != null ? var.service_account : data.google_compute_default_service_account.this.email}"
}