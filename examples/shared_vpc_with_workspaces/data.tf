data "google_compute_subnetwork" "this" {
  for_each = var.regions[local.region]["subnetworks"]
  name     = each.key
  region = local.region
//  region   = lookup(each.value, "region", local.region) == "" ? local.region : each.value.region
}

locals {
  subnetwork_map        = { for subnetwork in data.google_compute_subnetwork.this : subnetwork.name => subnetwork.self_link }
  subnetwork_map_detail = { for subnetwork in data.google_compute_subnetwork.this : subnetwork.name => subnetwork }
}