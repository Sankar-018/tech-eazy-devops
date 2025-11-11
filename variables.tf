#############################################
# VARIABLES - Tech-Eazy Terraform Deployment
#############################################

variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type (Free Tier eligible)"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "AWS Key Pair name for SSH access"
  type        = string
  default     = "AWS_keypair" 
}

variable "git_repo" {
  description = "GitHub repository to clone for app deployment"
  type        = string
  default     = "https://github.com/Trainings-TechEazy/test-repo-for-devops.git"
}

variable "stage" {
  description = "Deployment stage (dev/prod)"
  type        = string
  default     = "dev"
}

variable "stop_after_minutes" {
  description = "Time in minutes before instance shuts down automatically"
  type        = number
  default     = 60
}
