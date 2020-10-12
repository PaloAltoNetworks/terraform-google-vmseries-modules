locals {
  workspace_split_region = split("+", terraform.workspace)
  region                 = element(local.workspace_split_region, 1)
  workspace_split_environment = split("-", terraform.workspace)
  environment                 = element(local.workspace_split_environment, 1)
}