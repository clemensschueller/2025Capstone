# RDS Subnet Group
resource "aws_db_subnet_group" "wordpress" {
  name       = "wordpress-db-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id] # Using both private subnets for high availability

  tags = {
    Name = "WordPress DB Subnet Group"
  }
}

