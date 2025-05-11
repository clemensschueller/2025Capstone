# Output the public IP
output "public_ip" {
  value = aws_instance.wordpress_primary.public_ip
}

# Output the RDS endpoint
output "rds_endpoint" {
  value = aws_db_instance.wordpress.endpoint
}

# Output the database name
output "database_name" {
  value = aws_db_instance.wordpress.db_name
}

# Output NAT Gateway status
output "nat_gateway_status" {
  value = var.create_nat_gateway ? "ACTIVE - Costing approximately $0.045/hour + data transfer" : "DISABLED - No costs incurred"
}

# Output the ALB DNS name
output "alb_dns_name" {
  value = aws_lb.wordpress.dns_name
}

# Output the Auto Scaling Group name
output "asg_name" {
  value = aws_autoscaling_group.wordpress.name
}
