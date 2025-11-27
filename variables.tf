variable "aws_region" {
  default = "ap-south-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "AWS_keypair"
}

variable "stage" {
  default = "dev"
}

variable "instance_count" {
  default = 2
}

variable "stop_after_minutes" {
  default = 60
}

variable "s3_object_key" {
  default = "app.jar"
}

variable "local_app_artifact" {
  default = ""
}

variable "alert_email" {
  description = "Email address to receive SNS alerts"
  type        = string
  default     = "sankar01820@gmail.com"
}
