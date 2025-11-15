#############################################
# MAIN CONFIGURATION - Tech-Eazy HA Deployment
#############################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

#############################################
# AMI, VPC, SUBNETS
#############################################

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

#############################################
# S3 BUCKET FOR APP BUILDS
#############################################

resource "aws_s3_bucket" "app_builds" {
  bucket = "techeazy-devops-app-builds"

  tags = {
    Name = "techeazy-devops-app-builds"
    Env  = var.stage
  }
}

resource "aws_s3_bucket_object" "app_jar" {
  count  = var.local_app_artifact == "" ? 0 : 1
  bucket = aws_s3_bucket.app_builds.id
  key    = var.s3_object_key
  source = var.local_app_artifact
  etag   = filemd5(var.local_app_artifact)
}

#############################################
# IAM ROLE FOR S3 ACCESS
#############################################

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ec2_s3_role" {
  name               = "tech-eazy-ec2-s3-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

data "aws_iam_policy_document" "s3_read" {
  statement {
    actions = ["s3:GetObject", "s3:ListBucket"]
    resources = [
      aws_s3_bucket.app_builds.arn,
      "${aws_s3_bucket.app_builds.arn}/*"
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "s3_read_policy" {
  name   = "tech-eazy-s3-read"
  policy = data.aws_iam_policy_document.s3_read.json
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.s3_read_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "tech-eazy-ec2-profile"
  role = aws_iam_role.ec2_s3_role.name
}

#############################################
# SECURITY GROUPS
#############################################

resource "aws_security_group" "lb_sg" {
  name   = "tech-eazy-lb-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web_sg" {
  name   = "tech-eazy-web-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#############################################
# EC2 INSTANCES (COUNT = 2)
#############################################

resource "aws_instance" "app_server" {
  count                  = var.instance_count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = element(data.aws_subnets.default.ids, 0)
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = templatefile("${path.module}/user_data.tpl", {
    bucket             = "techeazy-devops-app-builds"
    key                = var.s3_object_key
    stop_after_minutes = var.stop_after_minutes
  })

  tags = {
    Name  = "tech-eazy-${var.stage}-${count.index}"
    Stage = var.stage
  }
}

#############################################
# ALB + TG + LISTENER
#############################################

resource "aws_lb" "app_lb" {
  name               = "tech-eazy-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = data.aws_subnets.default.ids
}

resource "aws_lb_target_group" "app_tg" {
  name     = "tech-eazy-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path = "/"
    matcher = "200-399"
    interval = 30
    timeout = 5
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "tg_attach" {
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.app_server[count.index].id
  port             = 80
}

#############################################
# SNS + ALARMS
#############################################

resource "aws_sns_topic" "alerts" {
  name = "tech-eazy-alerts"
}

resource "aws_cloudwatch_metric_alarm" "instance_alarm" {
  count = var.instance_count

  alarm_name          = "instance-${count.index}-down"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "StatusCheckFailed_Instance"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 1
  evaluation_periods  = 1

  alarm_actions = [aws_sns_topic.alerts.arn]

  dimensions = {
    InstanceId = aws_instance.app_server[count.index].id
  }
}

