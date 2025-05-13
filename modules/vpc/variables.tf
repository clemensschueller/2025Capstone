variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
  default     = "wordpress-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}
