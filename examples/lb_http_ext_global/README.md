
# Example of various GCP load balancers

Initialize:

```bash
terraform init
```

First, apply only the instances (the step is only obligatory on Terraform version 0.12).

```bash
terraform apply --refresh=false --target modules.vmseries
```

Because of deficiencies of Terraform's `google` provider, often the resources are deemed created when in fact they cannot be used
for quite a long time. This is why deployment will likely require manual repeats:

```bash
terraform apply --refresh=false
# ... wait some seconds ...
terraform apply --refresh=false
# ... wait some seconds ...
terraform apply --refresh=false
```

Same for destruction:

```bash
terraform destroy
# ... wait some seconds ...
terraform destroy
# ... wait some seconds ...
terraform destroy
```

Setting `depends_on` doesn't seem to solve this deficiency. In particular the GLB healthcheck, even after `depends_on` succeeds, can sometimes take about 3-4 minutes more to become usable (during the wait it returns a mix of `404 Not Found` and `502 Bad Gateway`).
