# How to develop lb_http_ext_region

Use replacement symbols for about everything: 

```
google_compute_forwarding_rule
google_compute_region_backend_service
google_compute_region_target_http_proxy
google_compute_region_target_https_proxy
google_compute_region_ssl_certificate
google_compute_region_url_map
google_compute_region_health_check
```

Some attributes differ, e.g. for the `google_compute_region_backend_service` add:
```
backend {
       failover                     = lookup(backend.value, "failover", false)
}
```

and remove:

```
   security_policy = var.security_policy
   enable_cdn      = var.cdn
```
