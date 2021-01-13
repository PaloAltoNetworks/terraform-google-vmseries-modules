locals {
  workspace_split        = split("+", terraform.workspace)
  region                 = local.workspace_split[1]
  workspace_prefix_split = split("-", local.workspace_split[0])
  environment            = element(local.workspace_prefix_split, 1)
}
