variable "name" {
  description = "Name of the VM-Series instance."
  type        = string
}

variable "project" {
  default = null
  type    = string
}

variable "zone" {
  description = "Zone to deploy instance in."
  type        = string
}

variable "network_interfaces" {
  description = <<-EOF
  List of the network interface specifications.
  Available options:
  - `subnetwork`             - (Required|string) Self-link of a subnetwork to create interface in.
  - `private_ip_name`        - (Optional|string) Name for a private address to reserve.
  - `private_ip`             - (Optional|string) Private address to reserve.
  - `create_public_ip`       - (Optional|boolean) Whether to reserve public IP for the interface. Ignored if `public_ip` is provided. Defaults to 'false'.
  - `public_ip_name`         - (Optional|string) Name for a public address to reserve.
  - `public_ip`              - (Optional|string) Existing public IP to use.
  - `public_ptr_domain_name` - (Optional|string) Existing public PTR name to use.
  - `alias_ip_ranges`        - (Optional|list) List of objects that define additional IP ranges for an interface, as specified [here](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#ip_cidr_range)
  EOF
  type        = list(any)
}

variable "bootstrap_options" {
  description = <<-EOF
  VM-Series bootstrap options to pass using instance metadata.

  Proper syntax is a map, where keys are the bootstrap parameters.
  Example:
    bootstrap_options = {
      type            = dhcp-client
      panorama-server = 1.2.3.4
    }

  A list of available parameters: type, ip-address, default-gateway, netmask, ipv6-address, ipv6-default-gateway, hostname, panorama-server, panorama-server-2, tplname, dgname, dns-primary, dns-secondary, vm-auth-key, op-command-modes, op-cmd-dpdk-pkt-io, plugin-op-commands, dhcp-send-hostname, dhcp-send-client-id, dhcp-accept-server-hostname, dhcp-accept-server-domain, vm-series-auto-registration-pin-id, vm-series-auto-registration-pin-value, auth-key, authcodes, vmseries-bootstrap-gce-storagebucket, mgmt-interface-swap.

  For more details on the options please refer to [VM-Series documentation](https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/bootstrap-the-vm-series-firewall/create-the-init-cfgtxt-file/init-cfgtxt-file-components).
  EOF
  default     = {}
  type        = map(string)
  validation {
    condition = alltrue([
      for v in keys(var.bootstrap_options) :
      contains(
        ["type", "ip-address", "default-gateway", "netmask", "ipv6-address", "ipv6-default-gateway", "hostname", "panorama-server", "panorama-server-2", "tplname", "dgname", "dns-primary", "dns-secondary", "vm-auth-key", "op-command-modes", "op-cmd-dpdk-pkt-io", "plugin-op-commands", "dhcp-send-hostname", "dhcp-send-client-id", "dhcp-accept-server-hostname", "dhcp-accept-server-domain", "vm-series-auto-registration-pin-id", "vm-series-auto-registration-pin-value", "auth-key", "authcodes", "vmseries-bootstrap-gce-storagebucket", "mgmt-interface-swap"],
        v
      )
    ])
    error_message = "Error in validating bootstrap_options, for details see variable description."
  }
}

variable "ssh_keys" {
  description = "Public keys to allow SSH access for, separated by newlines."
  default     = null
  type        = string
}

variable "metadata" {
  description = "Other, not VM-Series specific, metadata to set for an instance."
  default     = {}
  type        = map(string)
}

variable "metadata_startup_script" {
  description = "See the [Terraform manual](https://www.terraform.io/docs/providers/google/r/compute_instance.html)"
  default     = null
  type        = string
}

variable "create_instance_group" {
  description = "Create an instance group, that can be used in a load balancer setup."
  default     = false
  type        = bool
}

variable "named_ports" {
  description = <<-EOF
  The list of named ports to create in the instance group:

  ```
  named_ports = [
    {
      name = "http"
      port = "80"
    },
    {
      name = "app42"
      port = "4242"
    },
  ]
  ```

  The name identifies the backend port to receive the traffic from the global load balancers.
  Practically, tcp port 80 named "http" works even when not defined here, but it's not a documented provider's behavior.
  EOF
  default     = []
}

variable "service_account" {
  description = "IAM Service Account for running firewall instance (just the email)"
  default     = null
  type        = string
}

variable "scopes" {
  default = [
    "https://www.googleapis.com/auth/compute.readonly",
    "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
  ]
  type = list(string)
}

variable "vmseries_image" {
  description = <<EOF
  The image name from which to boot an instance, including the license type and the version.
  To get a list of available official images, please run the following command:
  `gcloud compute images list --filter="name ~ vmseries" --project paloaltonetworksgcp-public --no-standard-images`
  EOF
  default     = "vmseries-flex-bundle1-1008h8"
  type        = string
}

variable "custom_image" {
  description = "The full URI to GCE image resource, the output of `gcloud compute images list --uri`. Overrides official image specified using `vmseries_image`."
  default     = null
  type        = string
}

variable "machine_type" {
  description = "Firewall instance machine type, which depends on the license used. See the [Terraform manual](https://www.terraform.io/docs/providers/google/r/compute_instance.html)"
  default     = "n1-standard-4"
  type        = string
}

variable "min_cpu_platform" {
  default = "Intel Broadwell"
  type    = string
}

variable "disk_type" {
  description = "Boot disk type. See [provider documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#type) for available values."
  default     = "pd-standard"
}

variable "labels" {
  description = "GCP instance lables."
  default     = {}
  type        = map(any)
}

variable "tags" {
  description = "GCP instance tags."
  default     = []
  type        = list(string)
}

variable "resource_policies" {
  default = []
  type    = list(string)
}

variable "dependencies" {
  default = []
  type    = list(string)
}
