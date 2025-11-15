output "alb_dns" {
  value = aws_lb.app_lb.dns_name
}

output "instance_ips" {
  value = [for i in aws_instance.app_server : i.public_ip]
}

output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}

output "s3_bucket_name" {
  value = aws_s3_bucket.app_builds.bucket
}
