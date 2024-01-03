terraform {
        required_providers {
        aws = {
              source = "hashicorp/aws"
              version = "~> 4.16" 
             }
        }
        required_version = ">= 1.2.0"
}

provider "aws" {
          region = "ap-south-1"
}

resource "aws_instance" "my_ec2_instance" {
          ami ="ami-03f4878755434977f"
          instance_type = "t2.micro"
          tags =  {
                  Name = "Terraform-Server-instance"
          }
}

output "ec2_public_ips" {
        value = aws_instance.my_ec2_instance.public_ip
}

resource "aws_s3_bucket" "my_s3_bucket" {
       bucket = "terraform-s3-bucket-uc123"
       tags = {
              Name = "terraform-s3-bucket-uc123"
              Environment = "Dev"
       }
}

resource "aws_vpc" "my_vpc"{
       cidr_block = "10.0.0.0/16"
       instance_tenancy = "default"
       enable_dns_support = "true"
       enable_dns_hostnames = "true"
       enable_classiclink = "false"
       tags = {
           Name = "MY-VPC"
       }
}

resource "aws_subnet" "my_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "subnet-1"
  }
}

data "aws_availability_zones" "azs" {}

variable "subnet_cidr" {
  # type = "list"
  default = ["10.0.1.0/24", "10.0.2.0/24","10.0.3.0/24"]
}

resource "aws_subnet" "my_vpc_subnets" {
  count = length(var.subnet_cidr)
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "${element(var.subnet_cidr, count.index)}"

  map_public_ip_on_launch = "true"
  availability_zone = "${element(data.aws_availability_zones.azs.names, count.index)}"
  tags = {
    Name = "my_vpc_subnet-${count.index+1}"
  }
}

resource "aws_internet_gateway" "my_vpc_gw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "My VPC IGW"
  }
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "my_vpc_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.my_vpc_gw.id}"
  }

  tags = {
    Name = "MY VPC Route Table"
  }
}

resource "aws_route_table_association" "rt-association" {
  count = length(var.subnet_cidr)
  subnet_id = "${element(aws_subnet.my_vpc_subnets.*.id, count.index)}"
  route_table_id = aws_route_table.my_vpc_route_table.id
}


