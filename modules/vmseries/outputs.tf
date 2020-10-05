output vm_names {
  value = [for v in google_compute_instance.vmseries : v.name]
}

output vm_self_link {
  value = [for v in google_compute_instance.vmseries : v.self_link]
}

output instance_group {
  value = [for v in google_compute_instance_group.vmseries : v.self_link]
}

output "firewall_interfaces" {
  value = {for fw in google_compute_instance.vmseries: fw.name => {for int in fw.network_interface: int.name => {
    network_ip = int.network_ip
    subnetwork = split("subnetworks/",int.subnetwork)[1]
  }}}
}