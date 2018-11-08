/*AWS Provider Configuration
*/
##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {
  default = "TECHDEN_KEY"
}
##################################################################################
# PROVIDERS
##################################################################################


provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "us-east-2"
    }

##################################################################################
# RESOURCES
##################################################################################

    resource "aws_instance" "Dev_Build_TEST01"{

        ami ="ami-0e28ec6753aeec976"
        instance_type = "t2.micro"
        key_name        = "${var.key_name}"
          connection {
    user        = "ec2-user"
    private_key = "${file(var.private_key_path)}"
  }

        tags {
            Name = "DEV_BUILD_TEST01"
            Use = "TestServer01"
        }
    

    }
        resource "aws_instance" "Dev_Build_TEST02"{

        ami ="ami-0e28ec6753aeec976"
        instance_type = "t2.micro"
         key_name        = "${var.key_name}"
         
        connection {
    user        = "ec2-user"
    private_key = "${file(var.private_key_path)}"
  }

            tags {
            Name = "DEV_BUILD_TEST02"
            Use = "TestServer02"
        }
    }
    