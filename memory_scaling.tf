#############################################
# MEMORY-BASED SCALING POLICIES (PR3)
#############################################

# Scale OUT when average mem_used_percent > 50%
resource "aws_autoscaling_policy" "memory_scale_out" {
  name                   = "memory-scale-out"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  policy_type            = "SimpleScaling"

  adjustment_type     = "ChangeInCapacity"
  scaling_adjustment  = 1          # add 1 instance
  cooldown            = 120
}

# Scale IN when average mem_used_percent < 30%
resource "aws_autoscaling_policy" "memory_scale_in" {
  name                   = "memory-scale-in"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  policy_type            = "SimpleScaling"

  adjustment_type     = "ChangeInCapacity"
  scaling_adjustment  = -1         # remove 1 instance
  cooldown            = 300
}

#############################################
# CLOUDWATCH ALARMS FOR MEMORY
#############################################

# High memory -> scale out
resource "aws_cloudwatch_metric_alarm" "memory_high" {
  alarm_name          = "memory-high-scale-out"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 50                         # Requirement: Memory > 50%
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  statistic           = "Average"
  period              = 60

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.memory_scale_out.arn]
}

# Low memory -> scale in
resource "aws_cloudwatch_metric_alarm" "memory_low" {
  alarm_name          = "memory-low-scale-in"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  threshold           = 30                         # scale back when < 30%
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  statistic           = "Average"
  period              = 60

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.memory_scale_in.arn]
}
