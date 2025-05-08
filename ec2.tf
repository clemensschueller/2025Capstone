# EC2 Instance
resource "aws_instance" "wordpress_primary" {
  ami                    = "ami-0d1bf5b68307103c2"  # Amazon Linux 2 in eu-central-1
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public[0].id  # Erstes Public Subnet (eu-central-1a)
  vpc_security_group_ids = [
    aws_security_group.ssh.id,
    aws_security_group.http.id
  ]
  user_data              = file("userdata_wordpress.sh")  # Pfad zu deinem Script

  tags = {
    Name = "WordPress-Primary"
  }
}


# Output the public IP
output "public_ip" {
  value = aws_instance.web_server.public_ip
}
