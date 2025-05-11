# Launch Template for Auto Scaling Group
resource "aws_launch_template" "wordpress" {
  name_prefix   = "wordpress-"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.ec2_instance_type_t2micro
  key_name      = "wordpress"

  vpc_security_group_ids = [
    aws_security_group.ssh_sg.id,
    aws_security_group.webserver_sg.id
  ]

  user_data = filebase64("userdata_wordpress.sh")

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 20
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "wordpress-asg-instance"
    }
  }

  tags = {
    Name = "wordpress-launch-template"
  }
}
