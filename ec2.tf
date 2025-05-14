# Primary WordPress Instance
resource "aws_instance" "wordpress_primary" {
  ami           = "ami-04999cd8f2624f834"
  instance_type = var.ec2_instance_type_t2micro
  subnet_id     = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids = [
    aws_security_group.ssh_sg.id,
    aws_security_group.webserver_sg.id
  ]
  associate_public_ip_address = true
  key_name                    = "vockey"
  user_data                   = file("user_data.sh") # Path to Script

  tags = {
    Name = "WordPress-Primary"
  }
}
