module "us_central1_delicense" {
  source             = "../../modules/autoscale_deliense"
  bucket_name        = var.bucket_name
  cloud_functions    = var.cloud_functions
  cfn_identity_name  = var.cfn_identity_name
  cfn_identity_roles = var.cfn_identity_roles
  project_id         = var.project
}