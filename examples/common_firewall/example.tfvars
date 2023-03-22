project_id = "example"
project    = "example"
region     = "us-central1"

allowed_sources = ["35.235.240.0/20", "35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22", "169.254.169.254/32", "10.0.0.0/8"]
# These are for GCP healthchecks: "35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22", "169.254.169.254/32"

vmseries = {
  fw01 = {
    name = "fw01"
    zone = "us-central1-a"
    private_ips = {
      mgmt    = "10.236.64.2"
      trust   = "10.236.64.35"
      untrust = "10.236.64.20"
    }
  }
  fw02 = {
    name = "fw02"
    zone = "us-central1-b"
    private_ips = {
      mgmt    = "10.236.64.3"
      trust   = "10.236.64.36"
      untrust = "10.236.64.21"
    }
  }
}
vmseries_common = {
  vmseries_image = "vmseries-flex-byol-1014"
  bootstrap_options = {
    mgmt-interface-swap = "enable"
  }
}

extlb_name = "example-external-lb"

service_account = "example-firewall"

# Public key needs to be added here
ssh_keys = "admin:<public-key>"