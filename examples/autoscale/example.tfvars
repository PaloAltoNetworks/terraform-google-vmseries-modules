public_key_path  = "id_rsa.pub"
private_key_path = "id_rsa"

networks = [
  {
    name            = "as4-untrust"
    subnetwork_name = "as4-untrust"
    ip_cidr_range   = "192.168.1.0/24"
    # Where from are you going to access the example site?:
    allowed_sources = ["199.167.52.0/22", "8.47.64.2/32", "208.184.7.0/24", "67.154.150.32/28", "208.184.44.128/27", "64.0.175.110/32", "64.124.146.186/32", "35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22", "124.33.177.32/28", "150.249.195.35/32", "203.116.44.82/32", "118.201.32.208/28", "111.223.77.192/27", "119.73.179.160/28", "125.17.6.254/32", "115.114.47.125/32", "96.92.92.64/28", "63.226.86.16/32", "213.39.97.34/32", "18.130.7.245/32", "84.207.227.0/28", "84.207.230.24/29", "213.208.209.160/30", "155.160.255.8/29", "182.74.171.144/29", "119.225.22.94/32", "13.239.13.13/32", "10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    # These are for GCP healthchecks: "35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22", "169.254.169.254/32"
  },
  {
    # Panorama's VPC, it should already exist - provide the names of already existing network/subnetwork.
    name              = "as4-mgmt"
    subnetwork_name   = "as4-mgmt"
    create_network    = false
    create_subnetwork = false
    # Where from are you going  to manage the example firewalls?:
    allowed_sources = ["199.167.52.0/22", "8.47.64.2/32", "208.184.7.0/24", "67.154.150.32/28", "208.184.44.128/27", "64.0.175.110/32", "64.124.146.186/32", "35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22", "124.33.177.32/28", "150.249.195.35/32", "203.116.44.82/32", "118.201.32.208/28", "111.223.77.192/27", "119.73.179.160/28", "125.17.6.254/32", "115.114.47.125/32", "96.92.92.64/28", "63.226.86.16/32", "213.39.97.34/32", "18.130.7.245/32", "84.207.227.0/28", "84.207.230.24/29", "213.208.209.160/30", "155.160.255.8/29", "182.74.171.144/29", "119.225.22.94/32", "13.239.13.13/32", "10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  },
  {
    name            = "as4-trust"
    subnetwork_name = "as4-trust"
    ip_cidr_range   = "192.168.2.0/24"
  },
]

fw_network_ordering = [
  "as4-untrust",
  "as4-mgmt",
  "as4-trust",
]

mgmt_network        = "as4-mgmt"
intlb_network       = "as4-trust"
intlb_global_access = true

service_account = "paloaltonetworks-fw"

# Aid in initial troubleshooting:
# fw_image_uri = "https://console.cloud.google.com/compute/imagesDetail/projects/nginx-public/global/images/nginx-plus-centos7-developer-v2019070118"
