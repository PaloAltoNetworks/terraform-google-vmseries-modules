# Example for GCP Auto-Scaling of Firewalls

## Caveat

1. The auto-scaling happens independently in each zone (it appears to be a limitation of GCP plugin 2.0.0 on Panorama, it simply does not check for the regional instance groups). The test was on Panorama 9.1.4.
2. The PanOS custom GCP metrics like `panSessionActive` require more work. See the GCP Metric Explorer.

## Instruction

- Set up all the VPCs.
- Set up Panorama. This example assumes it exists with proper settings.
- Set the GCP Service Account with the sufficient permissions. The account will not only be used for GCP plugin access, but also for actually running the instances.
- Go to the main directory of the example (i.e. where this README.md is placed)
- Put the created items into your `terraform.tfvars`:

```ini

mgmt_vpc          = "as4-mgmt-vpc"
mgmt_subnet       = ["as4-mgmt"]
mgmt_cidr         = ["192.168.0.0/24"]
untrust_vpc       = "as4-untrust-vpc"
untrust_subnet    = ["as4-untrust"]
untrust_cidr      = ["192.168.1.0/24"]
trust_vpc         = "as4-trust-vpc"
trust_subnet      = ["as4-trust"]
trust_cidr        = ["192.168.2.0/24"]

service_account   = "my-service-account@my-project.iam.gserviceaccount.com"
```

- Optionally, restrict the access to where your laptop(s) will access the example:

```ini
mgmt_sources      = ["199.167.52.0/22", "8.47.64.2/32", "208.184.7.0/24", "67.154.150.32/28", "208.184.44.128/27", "64.0.175.110/32", "64.124.146.186/32", "35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22", "124.33.177.32/28", "150.249.195.35/32", "203.116.44.82/32", "118.201.32.208/28", "111.223.77.192/27", "119.73.179.160/28", "125.17.6.254/32", "115.114.47.125/32", "96.92.92.64/28", "63.226.86.16/32", "213.39.97.34/32", "18.130.7.245/32", "84.207.227.0/28", "84.207.230.24/29", "213.208.209.160/30", "155.160.255.8/29", "182.74.171.144/29", "119.225.22.94/32", "13.239.13.13/32", "10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
                   # These are for GCP healthchecks: "35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22", "169.254.169.254/32"
```

- Put the SSH keys in the example's directory e.g.: `ssh-keygen -t rsa -C admin -N '' -f id_rsa`
- Manually edit the settings in `bootstrap_files/authcodes`
- Manually edit the settings in `bootstrap_files/init-cfg.txt`
- Deploy Terraform:

```sh
terraform init
terraform plan
terraform apply
```
