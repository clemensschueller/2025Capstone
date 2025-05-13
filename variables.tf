variable "ec2_instance_type_t2micro" {
  type        = string
  description = "value for the instance type"
  default     = "t2.micro"
}

variable "region_us_west_2" {
  type        = string
  description = "value for the region"
  default     = "us-west-2"
}

# # Variable to control NAT Gateway creation
# variable "create_nat_gateway" {
#   description = "Whether to create a NAT Gateway (true/false)"
#   type        = bool
#   default     = false # Default to off to save costs
# }
