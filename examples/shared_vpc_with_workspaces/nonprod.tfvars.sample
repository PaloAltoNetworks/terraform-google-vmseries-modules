regions = {
  us-central1 = {
    subnetworks = {
      "mgmt1-uscentral1"   = ""
      "shared1-uscentral1" = ""
      "dev1-uscentral1"    = ""
      "test1-uscentral1"   = ""
      "untrust-uscentral1" = ""
    }
    firewalls = {
      a1 = {
        fw_build = true
        zone     = "a"
        name     = "fw01"
        interfaces = {
          nic0 = {
            access_config = {
              ip_address = ""
            }
            ip_address = ""
            subnetwork = "untrust"
            allow = {
              rule1 = {
                protocol = "tcp"
                ports    = ["22"]
              }
              rule2 = {
                protocol = "udp"
                ports    = null
              }
            }
            deny = {
              rule1 = {
                protocol = "tcp"
                ports    = ["443", "8443", "80"]
              }
              rule2 = {
                protocol = "udp"
                ports    = ["53"]
              }
            }
          }
          nic1 = {
            access_config = {
              ip_address = ""
            }
            ip_address    = ""
            subnetwork    = "mgmt1-uscentral1"
            source_ranges = ["69.148.174.55/32", "1.1.1.1/32"]
            disabled      = true
            priority      = 75
          }
          nic2 = {
            ip_address = "10.200.4.100"
            subnetwork = "dev1-uscentral1"
          }
          nic3 = {
            ip_address = ""
            subnetwork = "shared1-uscentral1"
          }
          nic4 = {
            ip_address = ""
            subnetwork = "test1-uscentral1"
          }
        }
      }
      b1 = {
        zone = "b"
        name = "fw01"
        interfaces = {
          nic0 = {
            access_config = {
              ip_address = ""
            }
            ip_address = ""
            subnetwork = "untrust-uscentral1"
          }
          nic1 = {
            access_config = {
              ip_address = ""
            }
            ip_address = ""
            subnetwork = "mgmt1-uscentral1"
            disabled   = true
          }
          nic2 = {
            ip_address = ""
            subnetwork = "dev1-uscentral1"
          }
          nic3 = {
            ip_address = ""
            subnetwork = "shared1-uscentral1"
          }
          nic4 = {
            ip_address = ""
            subnetwork = "test1-uscentral1"
          }
        }
      }
    }

  }
  us-east4 = {
    subnetworks = {
      "mgmt1-useast4"   = ""
      "shared1-useast4" = ""
      "dev1-useast4"    = ""
      "test1-useast4"   = ""
      "untrust-useast4" = ""
    }
    firewalls = {
      a1 = {
        zone = "a"
        name = "fw01"
        interfaces = {
          nic0 = {
            access_config = {
              ip_address = ""
            }
            ip_address = ""
            subnetwork = "untrust-useast4"
          }
          nic1 = {
            access_config = {
              ip_address = ""
            }
            ip_address = ""
            subnetwork = "mgmt1-useast4"
          }
          nic2 = {
            ip_address = ""
            subnetwork = "dev1-useast4"
          }
          nic3 = {
            ip_address = ""
            subnetwork = "shared1-useast4"
          }
          nic4 = {
            ip_address = ""
            subnetwork = "test1-useast4"
          }
        }
      }
      b1 = {
        zone = "b"
        name = "fw01"
        interfaces = {
          nic0 = {
            access_config = {
              ip_address = ""
            }
            ip_address = ""
            subnetwork = "untrust"
          }
          nic1 = {
            access_config = {
              ip_address = ""
            }
            ip_address = ""
            subnetwork = "mgmt1-useast4"
          }
          nic2 = {
            ip_address = ""
            subnetwork = "dev1-useast4"
          }
          nic3 = {
            ip_address = ""
            subnetwork = "shared1-useast4"
          }
          nic4 = {
            ip_address = ""
            subnetwork = "test1-useast4"
          }
        }
      }
    }
  }
}
fw_machine_type  = "n1-standard-8"
public_key_path  = "PATH TO PUBLIC KEY USED FOR PANOS"
private_key_path = "PATH TO PRIVATE KEY USED IF USING ROUTE OPERATOR"