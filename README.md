# 🚀 Tech-Eazy DevOps Project — PR3: Auto Scaling, Monitoring & Alerts

This project extends **PR2 (High Availability)** by adding **Auto Scaling**, **Memory-Based Scaling**, **CPU-Based Scaling**, and **CloudWatch Monitoring** using AWS + Terraform.  
It simulates unpredictable workloads and responds by automatically scaling EC2 instances.

---

# 🎯 Project Goals (PR3)

### ✅ Implement Auto Scaling  
- Scale **out** when:
  - **CPU > 30%**
  - **Memory > 50%**
- Scale **in** when:
  - **CPU < 30%**
  - **Memory < 30%**

### ✅ Add CloudWatch Monitoring  
- Track **CPU usage**
- Track **memory usage (CloudWatch Agent)**
- Monitor **in-service instance count**
- Detect **EC2 failure or launch failure**

### ✅ Add Alerting via SNS  
You receive an **email alert** when:
- ASG instance count drops unexpectedly  
- CPU/Memory crosses threshold  
- EC2 instance becomes unhealthy  

---


---

# 📁 Folder Structure

```
tech-eazy-devops/
├── main.tf
├── alb.tf
├── autoscaling.tf
├── memory_scaling.tf
├── launch_template.tf
├── iam.tf
├── s3.tf
├── ami.tf
├── outputs.tf
├── variables.tf
├── variables.tfvars
├── sns_cloudwatch.tf
├── scripts/
│   └── load_generator.sh
├── policies/
│   ├── cw-agent-permissions.json
│   └── monitoring.json
└── user_data.tpl
```

---

# 🚀 Deployment Steps

### 1️⃣ Initialize Terraform  
```
terraform init
```

### 2️⃣ Validate configuration  
```
terraform validate
```

### 3️⃣ Deploy with variables file  
```
terraform apply -var-file=variables.tfvars
```

---

# 📊 Testing Auto Scaling

Use load generator:

```
./scripts/load_generator.sh <alb-dns>
```

This continuously hits `/hello` endpoint and increases CPU & memory usage.

---

# 🔍 How Memory Metrics Work  
- CloudWatch Agent installed via `user_data.tpl`
- Permissions granted via `cw-agent-permissions.json`
- Alarms use `mem_used_percent` metric

---

# 📨 Alerts

SNS delivers emails for:
- High CPU
- High Memory
- Low in-service instances
- Instance failure

---

# 🧹 Cleanup

```
terraform destroy -var-file=variables.tfvars
```

---

# ✔️ Notes for Reviewers  
- S3 bucket stores **app.jar**
- Launch template pulls JAR from S3
- Auto Scaling Group maintains state
- Alarm thresholds intentionally low for testing

---