terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.94.1"
    }
  }
}

provider "aws" {
    region = "eu-north-1"
}

# Create a VPC
resource "aws_vpc" "wordpress-vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "wordpress-vpc"
    }
}
