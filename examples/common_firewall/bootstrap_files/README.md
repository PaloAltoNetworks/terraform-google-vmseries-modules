# Manual operation

This directory should contain files:

``` ini
authcodes
init-cfg.txt
```

1. The file `authcodes` is not committed to git, so that a random person couldn't mistakenly run their VM-series firewall on your licensing account.
Don't just add any authcode that you posses here, first set up Panorama for de-registering it. It's critical: autoscaling means
a lot of license registrations happen automatically, which means that without proper de-registration you will soon run out of the available
licenses. **Do not postpone it until "later".** Instead:

    - On Panorama, configure `license api-key`
    - Panorama supports only a single api-key which it uses to de-register all the existing and future devices.
    - Only use authcode from **the same Support Account** as the api-key, otherwise the de-registration will fail. (Particularly, for *demo* use Authcodes
    from Support Account *193870* rather than from ~~245~~).

2. The file `init-cfg.txt` contains credentials to Panorama, update these manually. Example contents:

    ``` ini
    type=dhcp-client
    op-command-modes=mgmt-interface-swap
    vm-auth-key=<vmauthkey>
    panorama-server=<panorama-ip>
    tplname=<panorama-template-stack>
    dgname=<panorama-device-group>
    dhcp-send-hostname=yes
    dhcp-send-client-id=yes
    dhcp-accept-server-hostname=yes
    dhcp-accept-server-domain=yes
    ```
