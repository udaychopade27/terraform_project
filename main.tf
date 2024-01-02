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

