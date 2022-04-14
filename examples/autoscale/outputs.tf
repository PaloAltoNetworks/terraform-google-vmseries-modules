output "jumphost_ssh_command" {
  value = "ssh -i ${var.private_key_path} admin@${module.jumphost.public_ips[0]}"
}