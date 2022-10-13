# Active/Passive High-Availability Deployment

## Example Overview

## Deploying the Example Deployment

First you will need to clone the Github repository locally, to do this run the following command:

```shell
git clone https://github.com/terraform-google-vmseries-modules
```

Now goto this example folder by running the following command:

```shell
cd examples/active_passive_ha
```

First we will need to set some variables for the deployment, make a copy of the provided example by running this command:

```shell
cp terraform.tfvars.example terraform.tfvars
```

Now edit the new `terraform.tfvars` file, an easy way to do this is using `nano` like this:
```shell
nano terraform.tfvars
```

Example 
```
region          = "europe-west2"
project_id      = "gcp-project-id-here"
prefix          = "example-ha"
allowed_sources = ["0.0.0.0/0"]
cidr_mgmt       = "192.168.0.0/24"
cidr_untrust    = "192.168.1.0/24"
cidr_trust      = "192.168.2.0/24"
cidr_ha2        = "192.168.3.0/24"
cidr_workload   = "192.168.4.0/24"
public_key_path = "~/.ssh/gcp-demo.pub"
```

Now we're ready to start the deployment. First we need to initialize Terraform.

```shell
terraform init
```

First we will create the `google_computer_address` resource called `external_nat_ip`. To do this we will target Terraform to only apply that 1 resource from the plan.
```shell
terraform apply -target google_compute_address.external_nat_ip
```

```shell
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```
When prompted review the plan and enter `yes` to proceed.

```shell

```

Now you are ready 

```shell
terraform apply
```

```shell
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

When prompted review the plan and enter `yes` to proceed.


```shell
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

external_nat_ip = "x.x.x.x"
vmseries01_access = "https://y.y.y.y"
vmseries02_access = "https://z.z.z.z"
```



## Test

```shell
gcloud compute ssh workload-vm
```

Check External IP
```shell
echo $(curl https://api.ipify.org -s)
```

```shell
while :
do
  timeout -k 2 2 ping -c 1  8.8.8.8 >> /dev/null
  if [ $? -eq 0 ]; then
    echo "$(date) -- Online -- Source IP = $(curl https://checkip.amazonaws.com -s --connect-timeout 1)"
  else
    echo "$(date) -- Offline"
  fi
  sleep 1
done
```


```
Wed Oct 12 16:40:18 UTC 2022 -- Online -- Source IP = x.x.x.x
Wed Oct 12 16:40:19 UTC 2022 -- Online -- Source IP = x.x.x.x
Wed Oct 12 16:40:20 UTC 2022 -- Online -- Source IP = x.x.x.x
Wed Oct 12 16:40:21 UTC 2022 -- Online -- Source IP = x.x.x.x
```

Perform Failover

```
Wed Oct 12 16:47:18 UTC 2022 -- Online -- Source IP = x.x.x.x
Wed Oct 12 16:47:19 UTC 2022 -- Online -- Source IP = x.x.x.x
Wed Oct 12 16:47:21 UTC 2022 -- Offline
Wed Oct 12 16:47:22 UTC 2022 -- Offline
Wed Oct 12 16:47:23 UTC 2022 -- Online -- Source IP = x.x.x.x
Wed Oct 12 16:47:24 UTC 2022 -- Online -- Source IP = x.x.x.x
```


To Do!
- Need to change NAT Policy to LB IP - Circular Reference
- Need to change Loopback IP to LB IP - Circular Reference


Username: `admin`
Password: `Pal0Alt0@123`

