##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {
  default = "AWS_2016_Buildv1"
}
variable "network_address_space" {
  default = "10.199.0.0/16"
}
variable "subnet1_address_space" {
  default = "10.199.0.0/24"
}
variable "subnet2_address_space" {
  default = "10.199.1.0/24"
}

variable "instance_count" {
  default = 1
}

variable "subnet_count" {
  default = 2
}

