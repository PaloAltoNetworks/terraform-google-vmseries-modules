
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

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12, < 0.13 |
| google | = 3.30 |
| null | = 3.0 |

## Providers

| Name | Version |
|------|---------|
| google | = 3.30 |
| null | = 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| mgmt\_sources | n/a | `list` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| global\_url | n/a |
| internal\_url | n/a |
| regional\_url | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
