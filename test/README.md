# justlinux

Deploy a plain Linux image instead of Palo Alto Networks VM-Series image.
Set Linux to ip_forward all the traffic without any filtering.
Unsafe for any normal use, intended for initial troubleshooting of the connectivity. Only recommended on a *closed network*.

Bootstrap bucket or Panorama is not used/contacted at all with this setting.

The default image_uri becomes "debian-cloud-testing/debian-sid", but still remains customizable.