variable "project" {}
variable "region" {}
variable "name_prefix" {
  default = "example-"
}
variable "ssh_keys" {}
variable "custom_request_headers" {
  default = []
}