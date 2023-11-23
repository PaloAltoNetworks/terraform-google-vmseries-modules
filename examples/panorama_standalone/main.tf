module "vpc" {
  source = "../../modules/vpc"

  for_each = var.networks

  project_id                      = var.project
  name                            = "${var.name_prefix}${each.value.vpc_name}"
  create_network                  = each.value.create_network
  delete_default_routes_on_create = each.value.delete_default_routes_on_create
  mtu                             = each.value.mtu
  routing_mode                    = each.value.routing_mode
  subnetworks = { for k, v in each.value.subnetworks : k => merge(v, {
    name = "${var.name_prefix}${v.name}"
    })
  }
  firewall_rules = try({ for k, v in each.value.firewall_rules : k => merge(v, {
    name = "${var.name_prefix}${v.name}"
    })
  }, {})
}

module "panorama" {
  source = "../../modules/panorama"

  for_each = var.panoramas

  name              = "${var.name_prefix}${each.value.panorama_name}"
  project           = var.project
  region            = var.region
  zone              = each.value.zone
  panorama_version  = each.value.panorama_version
  ssh_keys          = each.value.ssh_keys
  subnet            = module.vpc[each.value.vpc_network_key].subnetworks[each.value.subnetwork_key].self_link
  private_static_ip = each.value.private_static_ip
  attach_public_ip  = each.value.attach_public_ip
  log_disks         = try(each.value.log_disks, [])
  depends_on        = [module.vpc]
}