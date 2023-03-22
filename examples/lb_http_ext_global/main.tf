module "vmseries" {
  for_each = {
    "${var.name_prefix}vm01" = {
      name = "${var.name_prefix}vm01"
      zone = data.google_compute_zones.available.names[0]
      network_interfaces = [
        {
          subnetwork       = local.subnet
          create_public_ip = true
        },
      ]
    }
    "${var.name_prefix}vm02" = {
      name = "${var.name_prefix}vm02"
      zone = data.google_compute_zones.available.names[1]
      network_interfaces = [
        {
          subnetwork       = local.subnet
          create_public_ip = true
        },
      ]
    }
  }
  source = "../../modules/vmseries/"

  name = each.value.name
  zone = each.value.zone

  network_interfaces = each.value.network_interfaces

  ## Any image will do, if only it exposes on port 80 the http url `/`:
  custom_image = "https://console.cloud.google.com/compute/imagesDetail/projects/nginx-public/global/images/nginx-plus-centos7-developer-v2019070118"
  machine_type = "g1-small"

  ssh_keys = var.ssh_keys

  create_instance_group = true
}

#########################################################################
# Global HTTP Load Balancer

module "glb" {
  source                = "../../modules/lb_http_ext_global"
  name                  = "${var.name_prefix}glb"
  backend_groups        = { for k, v in module.vmseries : k => module.vmseries[k].instance_group_self_link }
  max_rate_per_instance = 50000
}

#########################################################################
# Internal TCP/UDP Load Balancer
# 
# It's optional, just showing it can co-exist with a Global one.

module "ilb" {
  source     = "../../modules/lb_internal"
  name       = "${var.name_prefix}ilb"
  network    = local.vpc
  subnetwork = local.subnet
  all_ports  = true
  backends   = { for k, v in module.vmseries : k => module.vmseries[k].instance_group_self_link }
}

#########################################################################
# External Regional Network Load Balancer
#
# It's optional, just showing it can co-exist with other load balancers.

module "extlb" {
  source    = "../../modules/lb_external/"
  name      = "${var.name_prefix}extlb"
  instances = [for k, v in module.vmseries : module.vmseries[k].self_link]
  rules = {
    # Standard HTTP port:
    "tcp-80" = {
      port_range  = "80"
      ip_protocol = "TCP"
    }
    # A range of ports is possible as well:
    "tcp-4000-4002" = {
      port_range  = "4000-4002"
      ip_protocol = "TCP"
    }
    # Example of ICMP, it has no concept of ports:
    "icmp" = {
      port_range  = null
      ip_protocol = "ICMP"
    }
  }

  health_check_interval_sec        = 10
  health_check_healthy_threshold   = 2
  health_check_timeout_sec         = 5
  health_check_unhealthy_threshold = 3

  health_check_http_port         = 80
  health_check_http_request_path = "/"
  health_check_http_host         = "anything"
}

locals {
  # Ensure that `terraform destroy` can pass again even when the map is already destroyed.
  extlb_address = try(module.extlb.ip_addresses["tcp-80"], "")
}
