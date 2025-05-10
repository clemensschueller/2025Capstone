# NAT Gateway Elastic IP
resource "aws_eip" "nat" {
  count  = var.create_nat_gateway ? 1 : 0
  domain = "vpc"

  tags = {
    Name = "wordpress-nat-eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
  count         = var.create_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = module.vpc.public_subnet_ids[0] # Place in same AZ as Wordpress EC2 instance

  tags = {
    Name = "wordpress-nat-gateway"
  }

  # To ensure proper ordering
  depends_on = [module.vpc.igw_id]
}

# Update Private Route Table to route through NAT Gateway
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}
