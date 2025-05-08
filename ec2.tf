# EC2 Instance
data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "wordpress_primary" {
  ami                    = "ami-009082a6cd90ccd0e"  # Amazon Linux 2 in eu-central-1
  instance_type          = "t2.micro"
  subnet_id              = module.vpc.public_subnet_ids[0]  
  vpc_security_group_ids = [
    aws_security_group.ssh_sg.id,
    aws_security_group.webserver_sg.id
  ]
  user_data              = file("userdata_wordpress.sh")  # Path to Script

  tags = {
    Name = "WordPress-Primary"
  }
}


# Output the public IP
output "public_ip" {
  value = aws_instance.wordpress_primary.public_ip
}
