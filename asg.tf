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

# Auto Scaling Group
resource "aws_autoscaling_group" "wp-autoscaling-group" {
  name                = "wordpress-asg"
  desired_capacity    = 2
  min_size            = 1
  max_size            = 4
  vpc_zone_identifier = module.vpc.public_subnet_ids
  target_group_arns   = [aws_lb_target_group.wordpress.arn]
  health_check_type   = "ELB"
  default_cooldown    = 30 # Added for faster scaling during testing

  launch_template {
    id      = aws_launch_template.wordpress.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "wordpress-asg-instance"
    propagate_at_launch = true
  }

  # Wait for capacity to be available
  wait_for_capacity_timeout = "10m"
}
