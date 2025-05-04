terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.94.1"
    }
  }
}

# module "vpc" {
#   source = "./modules/vpc"
# }



# Create a VPC
resource "aws_vpc" "wordpress-vpc" {
    cidr_block = "10.0.0.0/24"


    tags = {
        Name = "wordpress-vpc"
    }
}

#Create a subnet
