resource "google_compute_route" "route" {
    for_each     = var.routes_to_ilb
    name         = each.value.name
    dest_range   = each.value.destination
    network      = each.value.network_name
    next_hop_ilb = each.value.next_hop_ilb
    priority     = each.value.priority

    lifecycle {
        create_before_destroy = true
    }
}
