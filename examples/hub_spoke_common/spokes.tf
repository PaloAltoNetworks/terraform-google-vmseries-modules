# ----------------------------------------------------------------------------------------------------------------
# Create the spoke networks

module "vpc_spoke1" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "~> 4.0"
  project_id                             = var.project_id
  network_name                           = "${local.prefix}spoke1-vpc"
  routing_mode                           = "GLOBAL"
  delete_default_internet_gateway_routes = true

  subnets = [
    {
      subnet_name   = "${local.prefix}${var.region}-spoke1"
      subnet_ip     = var.cidr_spoke1
      subnet_region = var.region
    }
  ]

  routes = [
    {
      name              = "${local.prefix}spoke1-to-ilbnh"
      description       = "Default route to VM-Series NGFW"
      destination_range = "0.0.0.0/0"
      next_hop_ilb      = cidrhost(var.cidr_trust, 10)
      #tags             = "egress-inet"
    }
  ]

  firewall_rules = [
    {
      name      = "${local.prefix}allow-all-spoke1"
      direction = "INGRESS"
      priority  = "100"
      ranges    = ["0.0.0.0/0"]
      allow = [
        {
          protocol = "all"
          ports    = []
        }
      ]
    }
  ]
}

module "vpc_spoke2" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "~> 4.0"
  project_id                             = var.project_id
  network_name                           = "${local.prefix}spoke2-vpc"
  routing_mode                           = "GLOBAL"
  delete_default_internet_gateway_routes = true

  subnets = [
    {
      subnet_name   = "${local.prefix}${var.region}-spoke2"
      subnet_ip     = var.cidr_spoke2
      subnet_region = var.region
    }
  ]

  routes = [
    {
      name              = "${local.prefix}spoke2-to-ilbnh"
      description       = "Default route to VM-Series NGFW"
      destination_range = "0.0.0.0/0"
      next_hop_ilb      = cidrhost(var.cidr_trust, 10)
      #next_hop_internet = "true"
      #tags             = "egress-inet"
    }
  ]

  firewall_rules = [
    {
      name      = "${local.prefix}allow-all-spoke2"
      direction = "INGRESS"
      priority  = "100"
      ranges    = ["0.0.0.0/0"]
      allow = [
        {
          protocol = "all"
          ports    = []
        }
      ]
    }
  ]
}


# ----------------------------------------------------------------------------------------------------------------
# Create VPC peering connections between spoke networks and the trust network

resource "google_compute_network_peering" "spoke1_to_trust" {
  name         = "${local.prefix}spoke1-to-trust"
  network      = module.vpc_spoke1.network_id
  peer_network = module.vpc_trust.network_id
}

resource "google_compute_network_peering" "trust_to_spoke1" {
  name         = "${local.prefix}trust-to-spoke1"
  network      = module.vpc_trust.network_id
  peer_network = module.vpc_spoke1.network_id
}

resource "google_compute_network_peering" "spoke2_to_trust" {
  name         = "${local.prefix}spoke2-to-trust"
  network      = module.vpc_spoke2.network_id
  peer_network = module.vpc_trust.network_id
}

resource "google_compute_network_peering" "trust_to_spoke2" {
  name         = "${local.prefix}trust-to-spoke2"
  network      = module.vpc_trust.network_id
  peer_network = module.vpc_spoke2.network_id
}


# ----------------------------------------------------------------------------------------------------------------
# Create spoke1 compute instances with internal load balancer

resource "google_compute_instance" "spoke1_vm" {
  count                     = 2
  name                      = "${local.prefix}spoke1-vm${count.index + 1}"
  machine_type              = var.spoke_vm_type
  zone                      = data.google_compute_zones.main.names[0]
  can_ip_forward            = false
  allow_stopping_for_update = true

  metadata = {
    serial-port-enable = true
    ssh-keys           = fileexists(var.public_key_path) ? "paloalto:${file(var.public_key_path)}" : ""
  }

  network_interface {
    subnetwork = module.vpc_spoke1.subnets_self_links[0]
    #network_ip = cidrhost(var.cidr_spoke1, 10)
  }

  boot_disk {
    initialize_params {
      image = var.spoke_vm_image
    }
  }

  service_account {
    scopes = var.spoke_vm_scopes
  }
}


resource "google_compute_instance_group" "spoke1_ig" {
  name = "${local.prefix}spoke1-ig"
  zone = data.google_compute_zones.main.names[0]

  instances = google_compute_instance.spoke1_vm.*.id
}

module "spoke1_ilb" {
  source = "../../modules/lb_tcp_internal"

  name       = "${local.prefix}spoke1-ilb"
  backends   = { 0 = google_compute_instance_group.spoke1_ig.self_link }
  ip_address = cidrhost(var.cidr_spoke1, 10)
  subnetwork = module.vpc_spoke1.subnets_self_links[0]
  network    = module.vpc_spoke1.network_id

  all_ports = false

  timeout_sec       = 1
  ports             = [80]
  health_check_port = 80

}


# ----------------------------------------------------------------------------------------------------------------
# Create spoke2 compute instances. 

resource "google_compute_instance" "spoke2_vm1" {
  name                      = "${local.prefix}spoke2-vm1"
  machine_type              = var.spoke_vm_type
  zone                      = data.google_compute_zones.main.names[0]
  can_ip_forward            = false
  allow_stopping_for_update = true

  metadata = {
    serial-port-enable = true
    ssh-keys           = fileexists(var.public_key_path) ? "paloalto:${file(var.public_key_path)}" : ""
  }

  network_interface {
    subnetwork = module.vpc_spoke2.subnets_self_links[0]
    network_ip = cidrhost(var.cidr_spoke2, 10)
  }

  boot_disk {
    initialize_params {
      image = var.spoke_vm_image
    }
  }

  service_account {
    scopes = var.spoke_vm_scopes
  }
}


