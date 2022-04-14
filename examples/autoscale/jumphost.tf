module "jumpvpc" {
  source = "../../modules/vpc"
  networks = [
    {
      name            = "pso-customer-panorama"
      subnetwork_name = "pso-customer-panorama-jumphost"
      create_network  = false
      ip_cidr_range   = "192.168.13.0/24"
    },
  ]
  region = "europe-west4"
}

resource "google_compute_firewall" "this" {
  for_each = module.jumpvpc.networks

  name          = "${each.value.name}-jumpbox-ingress"
  network       = each.value.self_link
  direction     = "INGRESS"
  source_ranges = var.networks[0].allowed_sources
  target_tags   = ["jumphost"]

  allow {
    protocol = "tcp"
    ports    = ["22", "443"]
  }
}

# Spawn the VM-series firewall as a Google Cloud Engine Instance.
module "jumphost" {
  source = "../../modules/vmseries"

  name            = "as4-jumphost01"
  zone            = "us-central1-c"
  ssh_keys        = "admin:${file(var.public_key_path)}"
  custom_image    = "https://www.googleapis.com/compute/v1/projects/centos-cloud/global/images/centos-7-v20220303"
  tags            = ["jumphost"]
  service_account = module.iam_service_account.email
  network_interfaces = [
    {
      name             = "as4-jumphost01-mgmt"
      subnetwork       = try(module.vpc.subnetworks[var.mgmt_network].self_link, null)
      create_public_ip = true
    }
  ]
}

resource "null_resource" "jumphost_ssh_priv_key" {
  for_each = module.jumphost.public_ips[0]

  connection {
    type        = "ssh"
    user        = "admin"
    private_key = file(var.private_key_path)
    host        = each.value
  }

  provisioner "file" {
    source      = var.private_key_path
    destination = "key"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod go-rwx -R key",
      "echo 'Manage firewalls:    ssh  -i key  admin@internal_ip_of_firewall'",
    ]
  }
}
