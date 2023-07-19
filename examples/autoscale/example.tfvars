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

#---------------------------------------------------------------------------------
# (Optional) Panorama Software Firewall License Plugin

# panorama_auth_key = "_XX__0qweryQWERTYqwertyQWERTGrp"

#---------------------------------------------------------------------------------
# (Optional) Delicensing Cloud Function

# delicensing_cloud_function_config =   {
#   name_prefix           = "abc-"
#   function_name         = "delicensing-cfn"
#   region                = "us-central1"
#   bucket_location       = "US"
#   panorama_address      = "1.1.1.1"
#   vpc_connector_network = "panorama-vpc"
#   vpc_connector_cidr    = "10.10.190.0/28"
# }

#---------------------------------------------------------------------------------
# (Optional) Test VMs

# test_vms = {
#   "vm1" = {
#     "zone" : "us-central1-a"
#   }
# }

