# RDS Subnet Group
resource "aws_db_subnet_group" "wordpress" {
  name       = "wordpress-db-subnet-group"
  subnet_ids = [module.vpc.private_subnet_ids[0], module.vpc.private_subnet_ids[1]] # Using both private subnets for high availability

  tags = {
    Name = "WordPress DB Subnet Group"
  }
}

# RDS Instance
resource "aws_db_instance" "wordpress" {
  allocated_storage      = 10
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  identifier             = "wordpress-mysql"
  db_name                = "wordpressdb"
  username               = "admin"
  password               = "Admin123!" # In production, use aws_secretsmanager_secret or similar
  parameter_group_name   = aws_db_parameter_group.wordpress.name
  db_subnet_group_name   = aws_db_subnet_group.wordpress.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  multi_az               = false # Set to true for production
  storage_encrypted      = false # Set true for better security in production

  tags = {
    Name = "wordpress-database"
  }
}

# RDS Parameter Group
resource "aws_db_parameter_group" "wordpress" {
  name   = "wordpress-mysql-params"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}
