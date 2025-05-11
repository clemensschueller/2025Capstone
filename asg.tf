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

  user_data = base64encode(templatefile("${path.module}/userdata_wordpress.tpl", {
    rds_endpoint = aws_db_instance.wordpress.endpoint
  }))

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

# Auto Scaling Policy - Scale Up
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "wordpress-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.wp-autoscaling-group.name
}

# CloudWatch Alarm - High CPU
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "wordpress-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Scale up if CPU > 70% for 4 minutes"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.wp-autoscaling-group.name
  }
}

# Auto Scaling Policy - Scale Down
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "wordpress-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.wp-autoscaling-group.name
}

# CloudWatch Alarm - Low CPU
resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "wordpress-low-cpu"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 30
  alarm_description   = "Scale down if CPU < 30% for 4 minutes"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.wp-autoscaling-group.name
  }
}
