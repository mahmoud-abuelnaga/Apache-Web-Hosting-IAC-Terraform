resource "aws_autoscaling_group" "vprofile_asg" {
  min_size = var.asg_min
  desired_capacity = var.asg_desired
  max_size = var.asg_max

  vpc_zone_identifier = [
    aws_subnet.vprofile_private_subnet_1a.id,
    aws_subnet.vprofile_private_subnet_1b.id
  ]

  target_group_arns = [
    aws_lb_target_group.vprofile_target_group.arn
  ]

  launch_template {
    id = aws_launch_template.vprofile_launch_template.id
    version = "$Latest"
  }

  lifecycle {
    ignore_changes = [ desired_capacity ]
  }

  health_check_type = "ELB"
  default_cooldown = 300
}

resource "aws_autoscaling_policy" "vprofile_asg_cpu_policy" {
  name                   = "vprofile-asg-cpu-policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.vprofile_asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
    disable_scale_in = false
  }

  estimated_instance_warmup = 300
}