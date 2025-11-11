#############################################
# MAIN CONFIGURATION - Tech-Eazy Deployment
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
# Fetch Ubuntu 22.04 AMI (Canonical)
#############################################

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

#############################################
# Networking - Default VPC & Subnets
#############################################

# Default VPC and Subnets (AWS Provider v5+)
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
# Security Group - Allow HTTP (80) & SSH (22)
#############################################

resource "aws_security_group" "web_sg" {
  name        = "tech-eazy-web-sg"
  description = "Allow HTTP and SSH access"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
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

  tags = {
    Name = "tech-eazy-sg"
  }
}

#############################################
# EC2 Instance - Free Tier (t2.micro)
#############################################

resource "aws_instance" "app_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = element(data.aws_subnets.default.ids, 0)
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              set -eux
              apt-get update -y
              apt-get install -y git maven curl openjdk-21-jdk

              cd /opt
              git clone ${var.git_repo} app-repo
              cd app-repo
              mvn -B clean package

              JAR=$(ls target/*.jar | head -n 1)
              nohup java -jar "$JAR" --server.port=80 > /var/log/app.log 2>&1 &

              shutdown -h +${var.stop_after_minutes}
              EOF

  tags = {
    Name  = "tech-eazy-${var.stage}"
    Stage = var.stage
  }
}
