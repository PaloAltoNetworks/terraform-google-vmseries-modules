# General
variable "project" {}
variable "project_id" {}
variable "region" {}

# VPC
variable "vpc_name" {}
variable "subnet_name" {}
variable "cidr" {}
variable "allowed_sources" {}

# Panorama
variable "panorama_name" {}
variable "panorama_version" {}
variable "ssh_key" {}
variable "attach_public_ip" {}
variable "private_static_ip" {}
