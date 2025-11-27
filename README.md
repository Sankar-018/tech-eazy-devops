# Tech-Eazy DevOps Repo

## Overview
This project provisions a highly available application deployment on AWS using Terraform.  
It includes:
- Two EC2 instances
- Application Load Balancer (ALB)
- S3 bucket for application artifact storage
- CloudWatch Alarms for instance health
- SNS Topic for failure alerts
- IAM Roles for EC2 → S3 access
- Automated app deployment using user_data

---

## Architecture
1. **S3 Bucket**  
   Stores the built Spring MVC JAR file (`app.jar`).  
   Bucket Name: `techeazy-devops-app-builds`

2. **EC2 Instances (2x)**  
   - Launch template uses `user_data.tpl`
   - Downloads JAR from S3
   - Runs app on port `80`

3. **ALB**
   - Round-robin load balancing
   - Health checks on `/`

4. **CloudWatch Alarms**
   - Monitors `StatusCheckFailed_Instance`
   - Alerts via SNS if instance becomes `Unhealthy`

5. **SNS**
   - Sends email/SMS notifications

---

## Files Included

### **main.tf**
Contains:
- Providers  
- S3 bucket  
- IAM roles & policies  
- EC2 instances  
- ALB + target group + listener  
- CloudWatch alarms  
- SNS topic  

### **variables.tf**
Defines parameters:
- AWS region  
- Instance type  
- Key pair  
- S3 bucket name  
- Build artifact name  
- Alert email  
- Number of instances  

### **user_data.tpl**
Executed at instance boot:
- Installs AWS CLI  
- Downloads JAR from S3  
- Starts Spring MVC app  

### **outputs.tf**
Outputs:
- Public ALB DNS  
- EC2 public IPs  
- SNS topic ARN  

---

## Deployment Steps

```bash
terraform init
terraform plan
terraform apply -auto-approve