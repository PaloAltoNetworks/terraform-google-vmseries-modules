variable service_account_id {
  description = "The google_service_account.account_id of the created IAM account, unique string per project."
  default     = "fw-route-operator-api-sa"
  type        = string
}

variable service_account_display_name {
  default = "Palo Alto Networks route-operator-api Service Account"
}

resource "google_service_account" "this" {
  account_id   = var.service_account_id
  display_name = var.service_account_display_name
}

resource "google_project_iam_member" "compute_networkAdmin" {
  role   = "roles/compute.networkAdmin"
  member = "serviceAccount:${google_service_account.this.email}"
}

# resource "google_project_iam_custom_role" "routePrince" {
#   permissions = [
#     "compute.routes.create",
#     "compute.routes.delete",
#     "compute.routes.get",
#     "compute.routes.list",
#     "compute.networks.updatePolicy",
#     "compute.globalOperations.get",
#   ]
#   role_id = "routePrince"
#   title   = "Router Prince"
# }

# data "google_project" "this" {}

# resource "google_project_iam_member" "compute_networkAdmin" {
#   role   = "projects/${data.google_project.this.id}/roles/routePrince"
#   member = "serviceAccount:${google_service_account.this.email}"
# }

##################################################################

# module "service_accounts" {
#   source     = "terraform-google-modules/service-accounts/google"
#   version    = "~> 2.0"
#   project_id = lower(var.project_id)
#   prefix     = "failover"
#   names      = ["vm01"]
#   project_roles = [
#     "antontest1=>projects/antontest1/roles/routeKing",
#     "antontest1=>roles/iam.serviceAccountUser",
#   ]
# }
