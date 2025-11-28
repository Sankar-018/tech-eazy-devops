#############################################
# SNS TOPIC + EMAIL SUBSCRIPTION
#############################################

resource "aws_sns_topic" "alerts" {
  name = "tech-eazy-alerts"
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

#############################################
# CLOUDWATCH ALARM – In-service instances low
#############################################

resource "aws_cloudwatch_metric_alarm" "asg_in_service_low" {
  alarm_name          = "asg-in-service-instances-low"
  namespace           = "AWS/AutoScaling"
  metric_name         = "GroupInServiceInstances"
  comparison_operator = "LessThanThreshold"
  threshold           = 2                # if < 2 instances
  evaluation_periods  = 1
  period              = 60
  statistic           = "Minimum"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}
