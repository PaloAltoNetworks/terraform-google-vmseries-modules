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

resource google_compute_firewall this {
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
  instances = {
    "as4-jumphost01" = {
      name = "as4-jumphost01"
      zone = "europe-west4-c"
      network_interfaces = [
        {
          subnetwork = try(module.vpc.subnetworks[var.mgmt_network].self_link, null)
          public_nat = true
        },
      ]
    }
  }
  ssh_key         = "admin:${file(var.public_key_path)}"
  image_uri       = "https://console.cloud.google.com/compute/imagesDetail/projects/nginx-public/global/images/nginx-plus-centos7-developer-v2019070118"
  tags            = ["jumphost"]
  service_account = module.iam_service_account.email
}

output jumphost_ssh_command {
  value = { for k, v in module.jumphost.nic0_ips : k => "ssh  -i ${var.private_key_path}  admin@${v}" }
}

resource null_resource jumphost_ssh_priv_key {
  for_each = module.jumphost.nic0_ips

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
