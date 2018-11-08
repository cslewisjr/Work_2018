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
variable "network_address_space" {
  default = "10.1.0.0/16"
}
variable "subnet1_address_space" {
  default = "10.1.0.0/24"
}
variable "subnet2_address_space" {
  default = "10.1.1.0/24"
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
# DATA
##################################################################################

data "aws_availability_zones" "available" {}

##################################################################################
# RESOURCES
##################################################################################

# NETWORKING #
resource "aws_vpc" "vpc" {
  cidr_block = "${var.network_address_space}"
  enable_dns_hostnames = "true"

}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

}

resource "aws_subnet" "subnet1" {
  cidr_block        = "${var.subnet1_address_space}"
  vpc_id            = "${aws_vpc.vpc.id}"
  map_public_ip_on_launch = "true"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"

}

resource "aws_subnet" "subnet2" {
  cidr_block        = "${var.subnet2_address_space}"
  vpc_id            = "${aws_vpc.vpc.id}"
  map_public_ip_on_launch = "true"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"

}

# ROUTING #
resource "aws_route_table" "rtb" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
}

resource "aws_route_table_association" "rta-subnet1" {
  subnet_id      = "${aws_subnet.subnet1.id}"
  route_table_id = "${aws_route_table.rtb.id}"
}

resource "aws_route_table_association" "rta-subnet2" {
  subnet_id      = "${aws_subnet.subnet2.id}"
  route_table_id = "${aws_route_table.rtb.id}"
}
# SECURITY GROUPS #
# Windows security group 
resource "aws_security_group" "win16-sg" {
  name        = "win16_sg"
  vpc_id      = "${aws_vpc.vpc.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # RDP access
  ingress {
      from_port = 3389
      to_port   = 3389
      protocol  = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
}
# INSTANCES #
    resource "aws_instance" "Dev_Build_TEST01"{

        ami ="ami-0e28ec6753aeec976"
        instance_type = "t2.micro"
        subnet_id     = "${aws_subnet.subnet1.id}"
        vpc_security_group_ids = ["${aws_security_group.win16-sg.id}"]
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
        subnet_id     = "${aws_subnet.subnet1.id}"
        vpc_security_group_ids = ["${aws_security_group.win16-sg.id}"]
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
    