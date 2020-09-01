resource "google_compute_network_endpoint_group" "neg" {
    for_each = var.negs
    subnetwork   = each.value.subnet
    default_port = var.default_port
    name = each.value.name
    zone = each.value.zone
    network = each.value.network
}


resource "google_compute_network_endpoint" "default-endpoint" {
    for_each = var.firewalls
    network_endpoint_group = each.value.neg_name
    port = var.default_port
    ip_address = each.value.neg_ip
    instance = each.value.name
    zone = each.value.zone
}
