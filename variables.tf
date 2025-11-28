#############################################
# AWS Configuration
#############################################

variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
}

#############################################
# EC2 & Application Configuration
#############################################

variable "instance_type" {
  description = "EC2 instance type for the application"
  type        = string
}

variable "key_name" {
  description = "Name of the AWS key pair for SSH access"
  type        = string
}

variable "stage" {
  description = "Environment stage (dev/stage/prod)"
  type        = string
}

variable "stop_after_minutes" {
  description = "Auto-shutdown timer via user_data script"
  type        = number
}

variable "s3_object_key" {
  description = "Key name for the application JAR in S3"
  type        = string
}

variable "local_app_artifact" {
  description = "Local path to the JAR file for S3 upload (leave empty to skip)"
  type        = string
}

#############################################
# Alerts & Notifications
#############################################

variable "alert_email" {
  description = "Email address to receive SNS alerts"
  type        = string
}

#############################################
# Auto Scaling (PR3)
#############################################

variable "asg_min_size" {
  description = "Minimum number of instances for the Auto Scaling Group"
  type        = number
}

variable "asg_max_size" {
  description = "Maximum number of instances for the Auto Scaling Group"
  type        = number
}

variable "asg_desired_capacity" {
  description = "Desired number of instances for the Auto Scaling Group"
  type        = number
}
