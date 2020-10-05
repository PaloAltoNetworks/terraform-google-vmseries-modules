# Google Cloud Network Endpoint Groups

Network endpoint groups (NEGs) are zonal resources that represent 
collections of IP address and port combinations for GCP resources
within a single subnet. Each IP address and port combination is 
called a network endpoint.

This module can be use as a replacement for external load balancers based on Instance Groups

## Example

```terraform
module "neg" {
  source = "../modules/neg/"

  firewalls = {
    "0" = {
      name     = google_compute_instance.fw1.name
      neg_ip   = google_compute_instance.fw1.network_interface.0.network_ip
      neg_name = "neg-a"
      zone     = google_compute_instance.fw1.zone
    }
    "1" = {
      name     = google_compute_instance.fw2.name
      neg_ip   = google_compute_instance.fw2.network_interface.0.network_ip
      neg_name = "neg-b"
      zone     = google_compute_instance.fw2.zone
    }
  }

  negs = {
    "0" = {
      zone    = "europe-west4-a"
      name    = "neg-a"
      network = google_compute_instance.fw1.network_interface.0.network
      subnet  = google_compute_instance.fw1.network_interface.0.subnetwork
    }
   "1" = {
      zone    = "europe-west4-b"
      name    = "neg-b"
      network = google_compute_instance.fw2.network_interface.0.network
      subnet  = google_compute_instance.fw2.network_interface.0.subnetwork
    }
  }
}
```
