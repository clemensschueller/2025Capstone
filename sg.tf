# Security Group for SSH Admin Access
resource "aws_security_group" "ssh_sg" {
  name   = "wordpress-ssh-sg"
  vpc_id = aws_vpc.this.id
  description = "Allow SSH access to EC2 instances"
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
  name   = "Capstone-WebServer-SG"
  vpc_id = aws_vpc.this.id

  tags = {
    Name              = "WordpressWebServerSG"
    SecurityGroupName = "WordpressWebServerS"
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
