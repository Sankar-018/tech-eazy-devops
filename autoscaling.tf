#############################################
# AUTO SCALING GROUP
#############################################

resource "aws_autoscaling_group" "app_asg" {
  name                      = "tech-eazy-asg-${var.stage}"
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  desired_capacity          = var.asg_desired_capacity

  vpc_zone_identifier       = data.aws_subnets.available.ids
  target_group_arns         = [aws_lb_target_group.app_tg.arn]

  health_check_type         = "EC2"
  health_check_grace_period = 60
  default_cooldown          = 60

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "tech-eazy-${var.stage}"
    propagate_at_launch = true
  }
}

#############################################
# CPU TARGET TRACKING – >30% scale out
#############################################

resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "cpu-target-tracking"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    # Requirement: >30% CPU → scale out, <30% → scale in
    target_value     = 30
    disable_scale_in = false
  }
}
