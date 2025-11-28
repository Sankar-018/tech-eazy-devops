#############################################
# Essential Outputs for PR3
#############################################

output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = aws_lb.app_lb.dns_name
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app_asg.name
}

output "sns_topic_arn" {
  description = "SNS topic ARN for alerts"
  value       = aws_sns_topic.alerts.arn
}

#############################################
# Useful Debug & Demo Outputs
#############################################

output "target_group_arn" {
  description = "Target group used by ALB and ASG"
  value       = aws_lb_target_group.app_tg.arn
}

output "launch_template_id" {
  description = "Launch Template ID used by ASG"
  value       = aws_launch_template.app_lt.id
}

output "ami_id" {
  description = "AMI ID used by Launch Template"
  value       = data.aws_ami.ubuntu.id
}

output "asg_subnets" {
  description = "Subnets used by the Auto Scaling Group"
  value       = data.aws_subnets.available.ids
}
