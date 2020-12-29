# TODO: unfeasible to have it 3-4 minutes, see README.md
resource "null_resource" "delay_actual_use" {
  for_each = module.vmseries.nic0_ips

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = each.value
      private_key = file("~/.ssh/id_rsa")
      user        = "demo"
    }

    inline = [
      "sleep 5",
    ]
  }
  depends_on = [module.glb.all]
}

resource "null_resource" "verify_with_curl" {
  for_each = module.vmseries.nic0_ips

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = each.value
      private_key = file("~/.ssh/id_rsa")
      user        = "demo"
    }

    inline = [
      "printf '127:   '  &&  curl -m5 -sSi http://127.0.0.1 | head -1",
      "printf 'glb:   '  &&  curl -m5 -sSi http://${module.glb.address} | head -1",
      "printf 'ilb:   '  &&  curl -m5 -sSi http://${module.ilb.address} | head -1",
      "printf 'extlb: '  &&  curl -m5 -sSi http://${local.extlb_address} | head -1",
    ]
  }

  triggers = {
    run_me_every_time = "${timestamp()}"
  }

  depends_on = [null_resource.delay_actual_use]
}
