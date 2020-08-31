module "vm" {
  source      = "../../../modules/gcp/vm/"
  names       = ["my-vm01", "my-vm02"]
  zones       = [data.google_compute_zones.available.names[0], data.google_compute_zones.available.names[1]]
  subnetworks = ["my-subnet", "my-subnet"]

  ## Any image will do, if only it exposes on port 80 the http url `/`:
  image        = "https://console.cloud.google.com/compute/imagesDetail/projects/nginx-public/global/images/nginx-plus-centos7-developer-v2019070118"
  machine_type = "g1-small"

  ## The part before the colon is the ssh user name. The part after is intended to be replaced with your own ssh-rsa public key.
  ssh_key = "demo:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCbUVRz+1iNWsTVly/Xou2BUe8+ZEYmWymClLmFbQXsoFLcAGlK+NuixTq6joS+svuKokrb2Cmje6OyGG2wNgb8AsEvzExd+zbNz7Dsz+beSbYaqVjz22853+uY59CSrgdQU4a5py+tDghZPe1EpoYGfhXiD9Y+zxOIhkk+RWl2UKSW7fUe23UdXC4f+YbA0+Xy2l19g/tOVFgThHJn9FFdlQqlJC6a/0mWfudRNLCaiO5IbOlXIKvkLluWZ2GIMkr8uC5wldHyutF20EdAF9A4n72FssHCvB+WhrMCLspIgMfQA3ZMEfQ+/N5sh0c8vCZXV8GumlV4rN9xhjLXtTwf"

  create_instance_group = true
}

#########################################################################
# Global HTTP Load Balancer

module "glb" {
  source                = "../../../modules/gcp/lb_http_ext_global"
  name                  = "my-glb"
  backend_groups        = module.vm.instance_group
  max_rate_per_instance = 50000
}

output "global_url" {
  value = "http://${module.glb.address}"
}

#########################################################################
# Internal TCP Load Balancer
# 
# It's optional, just showing it can co-exist with a Global one.
# It is using secondary network interfaces, while the Global LB uses
# primary network interfaces.

module "ilb" {
  source            = "../../../modules/gcp/lb_tcp_internal"
  name              = "my-ilb"
  network           = "my-vpc"
  subnetworks       = ["my-subnet"]
  all_ports         = true
  ports             = []
  health_check_port = "22"

  backends = {
    "0" = [
      {
        group    = module.vm.instance_group[0],
        failover = false
      },
      {
        group    = module.vm.instance_group[1],
        failover = false
      }
    ]
  }
}

# output "internal_url" {
#   value = "http://${module.ilb.address}"   FIXME undefined
# }
