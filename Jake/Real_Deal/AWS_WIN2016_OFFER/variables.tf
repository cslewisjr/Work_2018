##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {
  default = "AWS_2016_Buildv2"
}
variable "network_address_space" {
  default = "10.199.0.0/16"
}
variable "environment_tag" {}
variable "bucket_name" {}

variable "arm_subscription_id" {}
variable "arm_principal" {}
variable "arm_password" {}
variable "tenant_id" {}
variable "dns_zone_name" {}
variable "dns_resource_group" {}
variable "dns_site_name" {}

variable "instance_count" {
  default = 4
}

variable "subnet_count" {
  default = 2
}

