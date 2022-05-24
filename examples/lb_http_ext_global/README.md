
# Example of various GCP load balancers

Because of deficiencies of Terraform's `google` provider, often the resources are deemed created when in fact they cannot be used
for quite a long time. This is why deployment will likely require manual repeats:

```bash
terraform apply
# ... wait some seconds ...
terraform apply
# ... wait some seconds ...
terraform apply
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
