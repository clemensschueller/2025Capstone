# Output the public IP
output "public_ip" {
  value = aws_instance.wordpress_primary.public_ip
}
