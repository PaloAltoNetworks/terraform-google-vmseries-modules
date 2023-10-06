project         = "example"
region          = "us-central1"
name            = "example-vmseries"
allowed_sources = ["1.1.1.1/32", "2.2.2.2/32"] # Replace these values with your own source CIDRs.
ssh_keys        = "admin:<public key>"
vmseries_image  = "vmseries-flex-byol-1020"
bootstrap_options = {
  hostname           = "vms01"
  panorama-server    = "10.1.2.3"
  plugin-op-commands = "numa-perf-optimize:enable,set-dp-cores:2"
  type               = "dhcp-client"
}
