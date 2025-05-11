# EC2 Instance
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Primary WordPress Instance
# hardcode ami ami-085386e29e44dacd7
resource "aws_instance" "wordpress_primary" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.ec2_instance_type_t2micro
  subnet_id     = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids = [
    aws_security_group.ssh_sg.id,
    aws_security_group.webserver_sg.id
  ]
  associate_public_ip_address = true
  key_name                    = "wordpress"
  user_data                   = filebase64("user_data.sh") # Path to Script

  tags = {
    Name = "WordPress-Primary"
  }
}
