variable "region" {
  description = "Google Cloud region to deploy the resources into."
  type        = string
}

variable "zone" {
  description = "Deployment area for Google Cloud resources within a region."
  type        = string
}

variable "subnet" {
  description = "A regional resource, defining a range of IPv4 addresses. In Google Cloud, the terms subnet and subnetwork are synonymous."
  type        = string
}

variable "project" {
  description = "The ID of the project in which the resource belongs. If it is not provided, the provider project is used."
  type        = string
  default     = "null"
}

variable "panorama_name" {
  description = "Name of the Panorama instance."
  type        = string
  default     = "panorama"
}

variable "private_static_ip" {
  description = <<EOF
  The static private IP address for Panorama. Only IPv4 is supported. An address may only be specified for INTERNAL address types.
  The IP address must be inside the specified subnetwork, if any. Set by the API if undefined.
  EOF
  type        = string
  default     = null
}

variable "attach_public_ip" {
  description = "Determines if a Public IP should be assigned to Panorama. Set by the API if the `public_static_ip` variable is not defined."
  type        = bool
  default     = false
}

variable "public_static_ip" {
  description = "The static external IP address for Panorama instance. Only IPv4 is supported. Set by the API if undefined."
  type        = string
  default     = null
}

variable "log_disk_type" {
  description = "Type of disk holding traffic logs. Default is pd-standard, alternative is pd-ssd or pd-balanced."
  type        = string
  default     = "pd-standard"
}

variable "log_disk_size" {
  description = "Size of disk holding traffic logs in gigabytes. Default is 2000."
  type        = string
  default     = "2000"
}

variable "machine_type" {
  description = "See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)"
  type        = string
  default     = "n1-standard-16"
}

variable "min_cpu_platform" {
  description = "See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)"
  type        = string
  default     = "Intel Broadwell"
}

variable "labels" {
  description = "See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)"
  type        = map(any)
  default     = {}
}

variable "tags" {
  description = "See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)"
  type        = list(string)
  default     = []
}

variable "disk_type" {
  description = "Type of boot disk. Default is pd-ssd, alternative is pd-balanced."
  type        = string
  default     = "pd-ssd"
}

variable "disk_size" {
  description = "Size of boot disk in gigabytes. Default is the same as the os image."
  type        = string
  default     = null
}

variable "ssh_key" {
  description = <<EOF
  In order to connect via SSH to Panorama, provide your SSH public key here.
  Remember to add the `admin` prefix before you insert your public SSH key.

  Example:

  `ssh_key = "admin:ssh-rsa AAAAB4NzaC5yc9EAACABBACBgQDAcjYw6xa2zUZ6reqHqDp9bYDLTu7Rnk5Sa3hthIsIsFaKenFLe4w3mm5eF3ebsfAAnuzI9ua9g7aB/ThIsIsAlSoFaKeN2VhUMDmlBYO5m1D4ip6eugS6uM="`
  EOF
  type        = string
}

variable "custom_image" {
  description = <<-EOF
  Custom image for your Panorama instances. Custom images are available only to your Cloud project. 
  You can create a custom image from boot disks and other images. 
  For more information, please check the provider [documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#image).
  
  If a `custom_image` is not specified, `image_project` and `image_family` are used to determine a Public image to use for Panorama.
  EOF
  type        = string
  default     = null
}

variable "image_project" {
  description = "For more information, please refer to the [Google Cloud documentation](https://cloud.google.com/compute/docs/images)"
  type        = string
  default     = "paloaltonetworksgcp-public"
}

variable "image_family" {
  description = "For more information, please refer to the [Google Cloud documentation](https://cloud.google.com/compute/docs/images)"
  type        = string
  default     = "panorama-10"
}

variable "metadata" {
  description = "See the [Terraform manual](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)"
  type        = map(string)
  default     = {}
}
