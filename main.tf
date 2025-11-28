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
# VPC + SUBNETS
#############################################

# Default VPC
data "aws_vpc" "default" {
  default = true
}

# All subnets in default VPC (kept for reference)
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Only use 2 AZs for ASG & ALB (avoid 1c issues)
data "aws_subnets" "available" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "availability-zone"
    values = [
      "ap-south-1a",
      "ap-south-1b"
    ]
  }
}

#############################################
# SECURITY GROUPS
#############################################

# ALB Security Group – HTTP from Internet
resource "aws_security_group" "lb_sg" {
  name   = "tech-eazy-lb-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 / ASG instances SG – traffic from ALB + SSH (for debug)
resource "aws_security_group" "web_sg" {
  name   = "tech-eazy-web-sg"
  vpc_id = data.aws_vpc.default.id

  # HTTP only from ALB
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  # SSH (optional – for debugging only)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

