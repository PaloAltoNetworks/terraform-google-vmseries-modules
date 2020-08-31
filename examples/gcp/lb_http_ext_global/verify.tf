
resource "null_resource" "delay_60s" {
  for_each = module.vm.nic0_public_ip

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = each.value
      private_key = file("~/.ssh/id_rsa")
      user        = "demo"
    }

    inline = [
      "sleep 60   # allow first healthchecks to succeed",
    ]
  }
}

resource "null_resource" "verify_with_curl" {
  for_each = module.vm.nic0_public_ip

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = each.value
      private_key = file("~/.ssh/id_rsa")
      user        = "demo"
    }

    inline = [
      "curl -sSi http://${module.glb.address} | head -1",
      "curl -sSi http://${module.extlb.forwarding_rule_ip_address} | head -1",
    ]
  }

  triggers = {
    run_me_every_time = "${timestamp()}"
  }

  depends_on = [null_resource.delay_60s]
}
