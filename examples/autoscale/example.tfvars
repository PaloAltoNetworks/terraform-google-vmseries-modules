project_id  = "my-project-id"
name_prefix = "example-"
region      = "us-central1"

cidr_mgmt       = "10.0.0.0/28"
cidr_untrust    = "10.0.1.0/28"
cidr_trust      = "10.0.2.0/28"
allowed_sources = ["0.0.0.0/0"]

vmseries_image_name    = "https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/vmseries-flex-byol-1023"
vmseries_instances_min = 1
vmseries_instances_max = 2

panorama_address        = "1.1.1.1"
panorama_device_group   = "autoscale-device-group"
panorama_template_stack = "autoscale-template-stack"
panorama_vm_auth_key    = "01234567890123456789"
