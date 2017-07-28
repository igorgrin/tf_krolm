# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags {
    Name        = "prod_vpc"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "b" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-west-2b"
}

resource "aws_elb" "www" {
  name = "main-elb"
  subnets         = ["${aws_subnet.default.id}"]
  security_groups = [
                      "${aws_security_group.ping.id}",
                      "${aws_security_group.http.id}"
                    ]
  instances       = ["${aws_instance.web.id}"]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

# Remote state file
resource "aws_s3_bucket" "kr_state" {
  bucket = "${var.bucket_name}"
  versioning {
    enabled = true
  }
  lifecycle {
    prevent_destroy = true
  }
}

terraform {
  required_version = ">= 0.9"
  backend "s3" {
    bucket = "kr-state"
    key    = "main/terraform.state"
    region = "us-west-2"
  }
}
