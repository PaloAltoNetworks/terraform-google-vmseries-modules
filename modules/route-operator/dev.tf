
resource "null_resource" "develop_locally" {
  count = var.develop_locally ? 1 : 0
  triggers = {
    file1 = filesha1(var.https_key_pem_file)
    file2 = filesha1(var.https_cert_pem_file)
    file3 = filesha1(var.https_interm_pem_file)
    file4 = yamlencode(local.ro_api_config)
  }
  #   provisioner "file" {
  #     source      = var.https_key_pem_file
  #     destination = "key.pem"
  #   }

  #   provisioner "file" {
  #     source      = var.https_cert_pem_file
  #     destination = "cert.pem"
  #   }

  #   provisioner "file" {
  #     source      = var.https_interm_pem_file
  #     destination = "interm.pem"
  #   }

  provisioner "local-exec" {
    command = <<-EOT
        echo '${yamlencode(local.ro_api_config)}'                        > '${path.module}/go/ro_api_config.yaml'
        cat '${var.https_cert_pem_file}' '${var.https_interm_pem_file}'  > '${path.module}/go/bundle.pem'
        cat '${var.https_key_pem_file}'                                  > '${path.module}/go/key.pem'
    EOT
  }
}
