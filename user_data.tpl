#!/bin/bash
set -eux

#############################################
# Update system & install dependencies
#############################################
apt-get update -y
apt-get install -y openjdk-21-jdk ruby wget curl unzip

#############################################
# Install AWS CLI v2
#############################################
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip /tmp/awscliv2.zip -d /tmp
/tmp/aws/install -i /usr/local/aws -b /usr/local/bin

#############################################
# Install CodeDeploy Agent (Ubuntu)
#############################################
cd /home/ubuntu
wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latest/install
chmod +x install
./install auto

systemctl enable codedeploy-agent
systemctl start codedeploy-agent

#############################################
# Install CloudWatch Agent
#############################################
wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i amazon-cloudwatch-agent.deb

#############################################
# CloudWatch Agent config
#############################################
mkdir -p /opt/aws/amazon-cloudwatch-agent/bin

cat >/opt/aws/amazon-cloudwatch-agent/bin/config.json <<'EOF'
{
  "metrics": {
    "metrics_collected": {
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      }
    },
    "append_dimensions": {
      "InstanceId": "$${aws:InstanceId}",
      "AutoScalingGroupName": "$${aws:AutoScalingGroupName}"
    }
  }
}
EOF

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json \
  -s

#############################################
# Create app directory (CodeDeploy will use this)
#############################################
mkdir -p /opt/app
