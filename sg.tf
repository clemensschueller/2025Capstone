# Security Group for SSH Admin Access
resource "aws_security_group" "ssh_sg" {
  name        = "wordpress-ssh-sg"
  vpc_id      = module.vpc.vpc_id
  description = "Allow SSH access to EC2 instances"

  tags = {
    Name              = "SSH_SG"
    SecurityGroupName = "SSH_SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh_sg_rule" {
  security_group_id = aws_security_group.ssh_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
  description = "Allow SSH access to EC2 instances"
}

resource "aws_vpc_security_group_egress_rule" "ssh_sg_rule_egress" {
  security_group_id = aws_security_group.ssh_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Security Group for HTTP & HTTPS
resource "aws_security_group" "webserver_sg" {
  name        = "Capstone-WebServer-SG"
  vpc_id      = module.vpc.vpc_id
  description = "HTTP & HTTPS traffic"

  tags = {
    Name              = "WordpressWebServerSG"
    SecurityGroupName = "WordpressWebServerSG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "webserver_sg_rule_http" {
  security_group_id = aws_security_group.webserver_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
  description = "Allow HTTP access to Wordpress EC2 instances"
}
resource "aws_vpc_security_group_egress_rule" "webserver_sg_rule_egress" {
  security_group_id = aws_security_group.webserver_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "webserver_sg_rule_https" {
  security_group_id = aws_security_group.webserver_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
  description = "Allow HTTPS access to Wordpress EC2 instances"
}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "Capstone-RDS-SG"
  description = "Allow traffic to RDS"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "rds_sg_rule" {
  security_group_id = aws_security_group.webserver_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 3306
  ip_protocol = "tcp"
  to_port     = 3306
  description = "Allow MySQL access to RDS"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_rds" {
  security_group_id = aws_security_group.rds_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "wordpress-alb-sg"
  description = "Security group for WordPress ALB"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "wordpress-alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow HTTP traffic"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow HTTPS traffic"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow all outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
