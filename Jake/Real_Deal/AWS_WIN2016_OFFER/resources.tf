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

    tag {
        Name = "${var.environment_tag}-vpc"
        Environment = "${var.environment_tag}"
    }

}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"


  tags {
    Name = "${var.environment_tag}-igw"
       Environment = "${var.environment_tag}"
  }

resource "aws_subnet" "subnet" {
  count = "${var.subnet_count}"  
  cidr_block        = "${cidrsubnet(var.network_address_space, 8, count.index + 1)}"
  vpc_id            = "${aws_vpc.vpc.id}"
  map_public_ip_on_launch = "true"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

}

# ROUTING #
resource "aws_route_table" "rtb" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
    tags {
    Name = "${var.environment_tag}-rtb"
    Environment = "${var.environment_tag}"
  }
}

resource "aws_route_table_association" "rta-subnet" {
  count = "${var.subnet_count}"  
  subnet_id      = "${aws_subnet.subnet1.id}"
  route_table_id = "${aws_route_table.rtb.id}"
}

}
# SECURITY GROUPS #
# Windows security group 
resource "aws_security_group" "elb-sg" {
  name        = "Win16_elb_sg"
  vpc_id      = "${aws_vpc.vpc.id}"

  #Allow HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.environment_tag}-elb-sg"
    Environment = "${var.environment_tag}"
  }

}
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
    tags {
    Name = "${var.environment_tag}-win16-sg"
    Environment = "${var.environment_tag}"
  }
}
# LOAD BALANCER #
resource "aws_elb" "web" {
  name = "${var.environment_tag}-win16-elb"

  subnets         = ["${aws_subnet.subnet.*.id}"]
  security_groups = ["${aws_security_group.elb-sg.id}"]
  instances       = ["${aws_instance.win16.*.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  tags {
    Name = "${var.environment_tag}-elb"
    Environment = "${var.environment_tag}"
  }

}
# INSTANCES #
    resource "aws_instance" "Test_"{

        ami ="ami-028779930ada5200c"
        count = "${var.instance_count}"
        instance_type = "t2.micro"
    tags { Name="${format("test-%01d",count.index+1)}" }
        subnet_id     = "${element(aws_subnet.subnet.*.id,count.index % var.subnet_count)}"
        vpc_security_group_ids = ["${aws_security_group.win16-sg.id}"]
        key_name        = "${var.key_name}"
         
          connection {
    user        = "ec2-user"
    private_key = "${file(var.private_key_path)}"
  }

      }