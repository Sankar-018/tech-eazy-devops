#!/bin/bash
set -eux

# Update & install dependencies
apt-get update -y
apt-get install -y openjdk-21-jdk curl unzip

# Install AWS CLI v2 correctly
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip /tmp/awscliv2.zip -d /tmp
/tmp/aws/install -i /usr/local/aws -b /usr/local/bin

# Create app folder
mkdir -p /opt/app

# Download JAR from S3
aws s3 cp "s3://${bucket}/${key}" /opt/app/app.jar

# Verify jar download
ls -lh /opt/app

# Run the application on port 80
nohup java -jar /opt/app/app.jar --server.port=80 > /var/log/app.log 2>&1 &

# Optional auto-shutdown
shutdown -h +${stop_after_minutes}
