project_id      = null
public_key_path = "~/.ssh/gcp-demo.pub"
region          = "us-central1"
prefix          = "panw"
cidr_mgmt       = "192.168.0.0/28"
cidr_untrust    = "192.168.1.0/28"
cidr_trust      = "192.168.2.0/28"
allowed_sources = ["0.0.0.0/0"]
#panorama_address        = "75.90.5.10"
#panorama_device_group   = "gcp-transit"
#panorama_template_stack = "gcp-transit_stack"
#panorama_vm_auth_key    = "0249501234560120"
vmseries_image_name   = "https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/vmseries-flex-bundle2-1014"
vmseries_per_zone_min = 1
vmseries_per_zone_max = 2
