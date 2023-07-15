module "us_central1_delicense" {
  source             = "../../modules/autoscale_delicense"
  bucket_name        = var.bucket_name
  cloud_functions    = var.cloud_functions
  cfn_identity_name  = var.cfn_identity_name
  cfn_identity_roles = var.cfn_identity_roles
  project_id         = var.project
  depends_on = [
    module.gcs_buckets
  ]
}

module "gcs_buckets" {
  source     = "terraform-google-modules/cloud-storage/google"
  version    = "~> 4.0"
  project_id = var.project
  names      = [var.cloud_functions.cf_autoscale_2.bucket_name]
  location   = "eu"
}
