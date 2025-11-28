#!/bin/bash
set -eux

#############################################
# Update & install dependencies
#############################################
apt-get update -y
apt-get install -y openjdk-21-jdk curl unzip wget

#############################################
# Install AWS CLI v2
#############################################
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip /tmp/awscliv2.zip -d /tmp
/tmp/aws/install -i /usr/local/aws -b /usr/local/bin

#############################################
# Install CloudWatch Agent (for memory metrics)
#############################################
wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i amazon-cloudwatch-agent.deb

#############################################
# Create CloudWatch Agent config (CPU/MEM)
#############################################
mkdir -p /opt/aws/amazon-cloudwatch-agent/bin

cat >/opt/aws/amazon-cloudwatch-agent/bin/config.json <<'EOF'
{
  "metrics": {
    "metrics_collected": {
      "mem": {
        "measurement": [
          "mem_used_percent"
        ],
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

#############################################
# Start CloudWatch Agent
#############################################
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json \
  -s

#############################################
# Create app folder
#############################################
mkdir -p /opt/app

#############################################
# Download JAR from S3
#############################################
aws s3 cp "s3://${bucket}/${key}" /opt/app/app.jar

# Verify jar download
ls -lh /opt/app

#############################################
# Run the application on port 80
#############################################
nohup java -jar /opt/app/app.jar --server.port=80 > /var/log/app.log 2>&1 &

#############################################
# Optional auto-shutdown
#############################################
shutdown -h +${stop_after_minutes}
