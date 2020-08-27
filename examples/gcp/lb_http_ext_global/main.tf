terraform {
  required_version = ">= 0.12, < 0.13"
}

provider "google" {
  version = "= 3.10"
}

data "google_compute_zones" "available" {}

module "vm" {
  source = "../../../modules/gcp/vm/"
  names  = ["my-vm01", "my-vm02"]
  zones  = [data.google_compute_zones.available.names[0], data.google_compute_zones.available.names[1]]
  subnetworks = [
    "untrust",
    # "pgs-mgmt-subnet", # FIXME
    # "pgs3-trust",
  ]
  machine_type = "g1-small"

  ## Any image will do, if only it exposes on port 80 the http url `/`:
  image = "https://console.cloud.google.com/compute/imagesDetail/projects/nginx-public/global/images/nginx-plus-centos7-developer-v2019070118"

  ## The part before colon is the ssh user name. The part after is intended to be replaced with your own ssh-rsa public key.
  ssh_key = "demo:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCbUVRz+1iNWsTVly/Xou2BUe8+ZEYmWymClLmFbQXsoFLcAGlK+NuixTq6joS+svuKokrb2Cmje6OyGG2wNgb8AsEvzExd+zbNz7Dsz+beSbYaqVjz22853+uY59CSrgdQU4a5py+tDghZPe1EpoYGfhXiD9Y+zxOIhkk+RWl2UKSW7fUe23UdXC4f+YbA0+Xy2l19g/tOVFgThHJn9FFdlQqlJC6a/0mWfudRNLCaiO5IbOlXIKvkLluWZ2GIMkr8uC5wldHyutF20EdAF9A4n72FssHCvB+WhrMCLspIgMfQA3ZMEfQ+/N5sh0c8vCZXV8GumlV4rN9xhjLXtTwf"

  create_instance_group = true
}

#########################################################################
# Global HTTP Load Balancer

module "glb" {
  source = "../../../modules/gcp/lb_http_ext_global"
  name   = "my-glb"
  backends = {
    "0" = [
      {
        group                        = module.vm.instance_group[0]
        balancing_mode               = "RATE"
        capacity_scaler              = null
        description                  = null
        max_connections              = null
        max_connections_per_instance = null
        max_rate                     = null
        max_rate_per_instance        = 50000
        max_utilization              = null
      },
      {
        group                        = module.vm.instance_group[1]
        balancing_mode               = "RATE"
        capacity_scaler              = null
        description                  = null
        max_connections              = null
        max_connections_per_instance = null
        max_rate                     = null
        max_rate_per_instance        = 50000
        max_utilization              = null
      }
    ]
  }
  backend_params = [
    // health check path, port name, port number, timeout seconds.
    "/,http,80,10"
  ]
}

output "global_url" {
  value = "http://${module.glb.address}"
}

#########################################################################
# Regional HTTP Load Balancer
# 
# It's optional, just showing it can co-exist together with a Global one.

