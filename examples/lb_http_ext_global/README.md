
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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12, < 0.13 |
| <a name="requirement_google"></a> [google](#requirement\_google) | = 3.48 |
| <a name="requirement_null"></a> [null](#requirement\_null) | = 2.1.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | = 3.48 |
| <a name="provider_null"></a> [null](#provider\_null) | = 2.1.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_extlb"></a> [extlb](#module\_extlb) | ../../modules/lb_tcp_external/ |  |
| <a name="module_glb"></a> [glb](#module\_glb) | ../../modules/lb_http_ext_global |  |
| <a name="module_ilb"></a> [ilb](#module\_ilb) | ../../modules/lb_tcp_internal |  |
| <a name="module_vmseries"></a> [vmseries](#module\_vmseries) | ../../modules/vmseries/ |  |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../../modules/vpc/ |  |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.builtin_healthchecks](https://registry.terraform.io/providers/hashicorp/google/3.48/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.extlb](https://registry.terraform.io/providers/hashicorp/google/3.48/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.ssh](https://registry.terraform.io/providers/hashicorp/google/3.48/docs/resources/compute_firewall) | resource |
| [null_resource.delay_actual_use](https://registry.terraform.io/providers/hashicorp/null/2.1.2/docs/resources/resource) | resource |
| [null_resource.verify_with_curl](https://registry.terraform.io/providers/hashicorp/null/2.1.2/docs/resources/resource) | resource |
| [google_compute_zones.available](https://registry.terraform.io/providers/hashicorp/google/3.48/docs/data-sources/compute_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_mgmt_sources"></a> [mgmt\_sources](#input\_mgmt\_sources) | n/a | `list` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_global_url"></a> [global\_url](#output\_global\_url) | n/a |
| <a name="output_internal_url"></a> [internal\_url](#output\_internal\_url) | n/a |
| <a name="output_regional_url"></a> [regional\_url](#output\_regional\_url) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
