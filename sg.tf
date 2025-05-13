# Security Group for HTTP & HTTPS
resource "aws_security_group" "webserver_sg" {
  name        = "Capstone-WebServer-SG"
  vpc_id      = module.vpc.vpc_id
  description = "HTTP & HTTPS traffic"

  # HTTP ingress
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP access to WordPress EC2 instances"
  }

  # HTTPS ingress
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS access to WordPress EC2 instances"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name              = "WordpressWebServerSG"
    SecurityGroupName = "WordpressWebServerSG"
  }
}

# Security Group for SSH Admin Access
resource "aws_security_group" "ssh_sg" {
  name        = "wordpress-ssh-sg"
  vpc_id      = module.vpc.vpc_id
  description = "Allow SSH access to EC2 instances"

  # SSH ingress
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH access to EC2 instances"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name              = "SSH_SG"
    SecurityGroupName = "SSH_SG"
  }
}
