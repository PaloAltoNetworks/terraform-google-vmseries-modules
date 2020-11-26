
# Nothing in this file is relevant to real deployments of Palo Alto Networks images.
#
# It only handles nonprod_just_linux which is intended for initial troubleshooting
# using a dummy linux image. It is not intended to be used outside of closed networks.
#
# Set Linux to ip_forward all the traffic without any filtering.
#
# Bootstrap bucket or Panorama is not used/contacted at all with this setting.
#
# The motivation is described on the now-rejected PR https://github.com/PaloAltoNetworks/terraform-google-vmseries-modules/pull/35

locals {
  # User-defined part of stratup script for instances.
  user_part = coalesce(var.metadata_startup_script, "\n")

  # Map of objects that will be used in startup script.
  metadata_startup_parameters = { for k, v in local.dyn_interfaces
    :
    k => {
      nic0cidr = try(v[0].subnetwork_cidr, "127.100.0.0/16")
      nic1cidr = try(v[1].subnetwork_cidr, v[0].subnetwork_cidr, "127.101.0.0/16")
      nic2cidr = try(v[2].subnetwork_cidr, v[0].subnetwork_cidr, "127.102.0.0/16")
      nic0gw   = try(v[0].subnetwork_gw, "127.100.0.1")
      nic1gw   = try(v[1].subnetwork_gw, v[0].subnetwork_gw, "127.101.0.1")
      nic2gw   = try(v[2].subnetwork_gw, v[0].subnetwork_gw, "127.102.0.1")
    }
  }

  # Map of startup scripts, interpolated and ready to run.
  metadata_startup_scripts = { for k, v in local.metadata_startup_parameters
    :
    k => !var.nonprod_just_linux ? null : <<-EOF
    #!/bin/bash
    #
    # The runtime logs are in the /var/log/syslog on Debian/Ubuntu for any metadata startup script.

    ############## Respond on port 80 ##############
    mkdir -p /tmp/www
    cd /tmp/www
    echo Hello > hi.txt
    sudo python3 -m http.server 80   &

    ############## Respond on port 443 ##############
    sudo openssl req -newkey rsa:2048 -nodes -x509 -subj '/CN=my.example.com' -days 3650 -out /server.cert -keyout /server.key
    sudo openssl s_server -accept 443 -cert /server.cert -key /server.key -www   &

    ############## Forward traffic ##############
    sudo sysctl net.ipv4.ip_forward=1
    sudo sysctl net.ipv4.conf.all.rp_filter=0
    sudo sysctl net.ipv4.conf | sed -n 's/[.]rp_filter = .*/.rp_filter = 0/p' | sudo sysctl -f -

    # assume three interfaces
    nic0=$( ls -1 /sys/class/net | grep -m1 ^e | tail -1 )
    nic1=$( ls -1 /sys/class/net | grep -m2 ^e | tail -1 )
    nic2=$( ls -1 /sys/class/net | grep -m3 ^e | tail -1 )
    echo "Interfaces and their subnet CIDRs:  0:$nic0=${v.nic0cidr} 1:$nic1=${v.nic1cidr} 2:$nic2=${v.nic2cidr}"
    echo "Default gateways:  0:$nic0=${v.nic0gw} 1:$nic1=${v.nic1gw} 2:$nic2=${v.nic2gw}"

    # main default route through "$nic1"
    sudo ip ro del default ; sudo ip ro add default via ${v.nic1gw}

    # routing table 10 is for $nic0
    sudo ip route add ${v.nic0gw} dev "$nic0" scope link table 10
    sudo ip route add default via ${v.nic0gw} table 10               # why: to return every healtheck probe through its ingress interface
    sudo ip route add ${v.nic2cidr} via ${v.nic2gw} table 10
    sudo ip route show table 10
    sudo ip rule add dev "$nic0" table 10
    sudo ip rule add from ${v.nic0cidr} table 10
    sudo ip route flush cache

    # routing table 12 is for $nic2
    # if $nic2 does not exist, the commands fail but nothing wrong/bad happens
    sudo ip route add ${v.nic2gw} dev "$nic2" scope link table 12
    sudo ip route add default via ${v.nic2gw} table 12               # why: to return every healtheck probe through its ingress interface
    sudo ip route add ${v.nic0cidr} via ${v.nic0gw} table 12
    # sudo ip route add 10.8.8.0/24 via ${v.nic0gw} table 12         # a faraway subnet
    sudo ip route show table 12
    sudo ip rule add dev "$nic2" table 12
    sudo ip rule add from ${v.nic2cidr} table 12
    sudo ip route flush cache

    ${local.user_part}
    EOF
  }
}
