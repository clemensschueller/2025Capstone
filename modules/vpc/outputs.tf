output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

output "private_subnet_ids" {
  value = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

output "igw_id" {
  value = aws_internet_gateway.this.id
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}
