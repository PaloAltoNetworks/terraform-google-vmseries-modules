project_id      = "gcp-gcs-pso"
project         = "gcp-gcs-pso"
region          = "us-central1"
region0         = "us-central1"
region1         = "us-east1"
name_prefix     = "example-"
allowed_sources = ["35.235.240.0/20", "35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22", "169.254.169.254/32", "10.0.0.0/8"]
# These are for GCP healthchecks: "35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22", "169.254.169.254/32"

vmseries_region0 = {
  fw01 = {
    name   = "fw01-us-central1"
    zone   = "us-central1-a"
    region = "us-central1"
    private_ips = {
      mgmt    = "10.236.64.2"
      trust   = "10.236.64.35"
      untrust = "10.236.64.20"
    }
  }
  fw02 = {
    name   = "fw02-us-central1"
    zone   = "us-central1-b"
    region = "us-central1"
    private_ips = {
      mgmt    = "10.236.64.3"
      trust   = "10.236.64.36"
      untrust = "10.236.64.21"
    }
  }
}

vmseries_region1 = {
  fw03 = {
    name   = "fw03-us-east1"
    zone   = "us-east1-c"
    region = "us-east1"
    private_ips = {
      mgmt    = "10.236.65.2"
      trust   = "10.236.65.35"
      untrust = "10.236.65.20"
    }
  }
  fw04 = {
    name   = "fw04-us-east1"
    zone   = "us-east1-b"
    region = "us-east1"
    private_ips = {
      mgmt    = "10.236.65.3"
      trust   = "10.236.65.36"
      untrust = "10.236.65.21"
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
ssh_keys = "admin:ssh-rsa AAAA....."

allow_global_access = true