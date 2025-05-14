# EC2 Instance
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Primary WordPress Instance
# hardcode ami "ami-04999cd8f2624f834"
resource "aws_instance" "wordpress_primary" {
  ami           = data.aws_ami.amazon_linux_2023.id
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
