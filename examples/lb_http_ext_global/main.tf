module "vmseries" {
  source = "../../modules/vmseries/"


  instances = {
    "my-vm01" = {
      name = "my-vm01"
      zone = data.google_compute_zones.available.names[0]
      network_interfaces = [
        {
          subnetwork = local.my_subnet
          public_nat = true
        },
      ]
    }
    "my-vm02" = {
      name = "my-vm02"
      zone = data.google_compute_zones.available.names[1]
      network_interfaces = [
        {
          subnetwork = local.my_subnet
          public_nat = true
        },
      ]
    }
  }

  ## Any image will do, if only it exposes on port 80 the http url `/`:
  image_uri    = "https://console.cloud.google.com/compute/imagesDetail/projects/nginx-public/global/images/nginx-plus-centos7-developer-v2019070118"
  machine_type = "g1-small"

  ## The part before the colon is the ssh user name. The part after is intended to be replaced with your own ssh-rsa public key.
  ssh_key = "demo:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCbUVRz+1iNWsTVly/Xou2BUe8+ZEYmWymClLmFbQXsoFLcAGlK+NuixTq6joS+svuKokrb2Cmje6OyGG2wNgb8AsEvzExd+zbNz7Dsz+beSbYaqVjz22853+uY59CSrgdQU4a5py+tDghZPe1EpoYGfhXiD9Y+zxOIhkk+RWl2UKSW7fUe23UdXC4f+YbA0+Xy2l19g/tOVFgThHJn9FFdlQqlJC6a/0mWfudRNLCaiO5IbOlXIKvkLluWZ2GIMkr8uC5wldHyutF20EdAF9A4n72FssHCvB+WhrMCLspIgMfQA3ZMEfQ+/N5sh0c8vCZXV8GumlV4rN9xhjLXtTwf"

  create_instance_group = true
}

#########################################################################
# Global HTTP Load Balancer

module "glb" {
  source                = "../../modules/lb_http_ext_global"
  name                  = "my-glb"
  backend_groups        = module.vmseries.instance_group_self_links
  max_rate_per_instance = 50000
}

output "global_url" {
  value = "http://${module.glb.address}"
}

#########################################################################
# Internal TCP Load Balancer
# 
# It's optional, just showing it can co-exist with a Global one.

module "ilb" {
  source     = "../../modules/lb_tcp_internal"
  name       = "my-ilb"
  network    = local.my_vpc
  subnetwork = local.my_subnet
  all_ports  = true
  backends   = module.vmseries.instance_group_self_links
}

output "internal_url" {
  value = "http://${module.ilb.address}"
}

#########################################################################
# External Regional TCP Load Balancer
#
# It's optional, just showing it can co-exist with other load balancers.

module "extlb" {
  source    = "../../modules/lb_tcp_external/"
  name      = "my-extlb"
  instances = values(module.vmseries.self_links)
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

output "regional_url" {
  value = "http://${local.extlb_address}"
}
