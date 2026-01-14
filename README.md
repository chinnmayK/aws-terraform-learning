# 🏗️ Terraform AWS Infrastructure Project – End-to-End (Phase 0 → Phase 10)

> **Goal:**
> Build, break, fix, modularize, scale, destroy, and rebuild a **production-grade AWS infrastructure** using **Terraform**, proving true infrastructure mastery.

This project was completed **phase by phase**, with real mistakes, real AWS errors, and real-world fixes — exactly how professional DevOps engineers learn.

---

## 📌 Technologies Used

* **Terraform**
* **AWS**

  * VPC
  * EC2
  * Security Groups
  * Application Load Balancer (ALB)
  * Target Groups
  * Auto Scaling Group (ASG)
  * Launch Templates
  * S3 (Remote State)
  * DynamoDB (State Locking)
* **Amazon Linux 2023**
* **Nginx**
* **Git & GitHub**

---

## 🧱 Project Architecture (Final)

```
Internet
   ↓
Application Load Balancer (Multi-AZ)
   ↓
Target Group
   ↓
Auto Scaling Group
   ↓
EC2 Instances (Amazon Linux + Nginx via user-data)
```

---

# 🔰 PHASE 0 – Terraform & AWS Setup

### What was done

* Installed Terraform
* Configured AWS CLI
* Verified AWS credentials
* Confirmed Terraform version
* Created project folder structure

### Outcome

✅ Terraform and AWS ready
✅ Environment verified before writing any code

---

# 🌐 PHASE 1 – Provider Configuration

### What was done

* Created `provider.tf`
* Configured AWS provider with region
* Verified provider initialization

### Outcome

✅ Terraform successfully connected to AWS

---

# 🏗️ PHASE 2 – Core Networking (VPC)

### What was done

* Created custom **VPC**
* Created:

  * Public subnet (AZ-1)
  * Public subnet (AZ-2)
  * Private subnet
* Attached **Internet Gateway**
* Created **Route Table**
* Associated route table with public subnets

### Key Learning

> ALB **requires at least two public subnets in different AZs**

### Outcome

✅ Custom networking foundation ready
✅ Multi-AZ networking enabled

---

# 🔐 PHASE 3 – Security Groups

### What was done

* Created **ALB Security Group**

  * HTTP (80) from `0.0.0.0/0`
* Created **EC2 Security Group**

  * SSH (22) from personal IP
  * HTTP (80) **only from ALB SG**

### Outcome

✅ Proper least-privilege security
✅ EC2 protected behind ALB

---

# 🖥️ PHASE 4 – EC2 Instance + Nginx

### What was done

* Created EC2 instance (Amazon Linux 2023)
* Used correct SSH user (`ec2-user`)
* Installed and started **Nginx**
* Verified:

  * SSH access
  * Browser access

### Major Learning

**Timeout error happened**
➡️ Root cause: HTTP (80) not allowed in EC2 SG
➡️ Fix: Temporarily allowed HTTP for testing

### Outcome

✅ EC2 + Nginx working
✅ Understood SG behavior deeply

---

# ⚖️ PHASE 5 – Application Load Balancer (ALB)

### What was done

* Created:

  * ALB
  * Target Group
  * Listener (HTTP :80)
* Attached EC2 to Target Group
* Fixed **ALB subnet error** by adding second public subnet

### Common Error Hit

```
ValidationError: At least two subnets in two different AZs must be specified
```

### Fix

* Added second public subnet
* Attached ALB to both subnets

### Outcome

✅ ALB serving traffic
✅ EC2 accessible only through ALB

---

# 📦 PHASE 6 – Variables & Outputs

### What was done

* Introduced:

  * `variables.tf`
  * `terraform.tfvars`
  * `outputs.tf`
* Removed hardcoded values
* Exposed:

  * ALB DNS
  * VPC ID

### Outcome

✅ Configurable infrastructure
✅ Cleaner Terraform code

---

# 🗄️ PHASE 7 – Remote State (S3 + DynamoDB)

### What was done

* Created S3 bucket for Terraform state
* Enabled bucket versioning
* Created DynamoDB table for state locking
* Migrated local state to S3 backend

### Outcome

✅ Team-safe Terraform
✅ State locking & recovery enabled

---

# 🧩 PHASE 8 – Terraform Modules (Most Difficult Phase)

### What was done

* Modularized entire infrastructure:

  * VPC module
  * Security Group module
  * EC2 module
  * ALB module
* Root `main.tf` became orchestration only
* Enforced strict module boundaries

### Major Real-World Mistakes (and Fixes)

#### ❌ Referencing resources from root

```
aws_instance.web_server not found
```

✅ Fixed by using **module outputs only**

---

#### ❌ Over-parameterizing everything

```
var.alb_name not declared
```

✅ Fixed by **hardcoding internal resource names inside modules**

---

#### ❌ Leftover variables like:

* `vpc_name`
* `instance_name`
* `listener_port`

✅ Fixed by:

* Removing unused variables
* Using constants where appropriate

---

#### ❌ Target group attachment inside ALB module (wrong for ASG)

✅ Fixed by moving responsibility to ASG

---

### Outcome

✅ Clean module contracts
✅ Enterprise-grade Terraform layout
✅ Deep understanding of module design

---

# 📈 PHASE 9 – Auto Scaling Group (ASG)

### What was done

* Removed standalone EC2
* Added:

  * Launch Template
  * Auto Scaling Group
* Added **user_data** to install nginx automatically
* Attached ASG to ALB target group

### Critical Learning

> With ASG:
>
> * You **do not manage EC2 instances directly**
> * You **do not output instance IDs or public IPs**

### Outcome

✅ Self-healing infrastructure
✅ Immutable EC2 instances
✅ True production architecture

---

# 💥 PHASE 10 – Destroy & Rebuild (Confidence Check)

### What was done

1. Ran:

   ```bash
   terraform destroy
   ```
2. Verified AWS was fully cleaned
3. Re-ran:

   ```bash
   terraform apply
   ```
4. Verified:

   * ALB DNS works
   * ASG launches EC2
   * Target group healthy
   * Nginx loads without manual intervention

### Outcome

✅ Full Terraform confidence
✅ Infrastructure is reproducible
✅ Code is the source of truth

---

# ❗ Common Mistakes (That Actually Happened)

| Mistake                     | Why it happened                          | How it was fixed                   |
| --------------------------- | ---------------------------------------- | ---------------------------------- |
| ALB 502 Bad Gateway         | Nginx not installed after EC2 recreation | Added user_data in Launch Template |
| ALB subnet error            | Only one public subnet                   | Added second subnet in another AZ  |
| SSH permission denied       | Wrong SSH user                           | Used correct user (`ec2-user`)     |
| Terraform validate failures | Undeclared variables                     | Removed over-parameterization      |
| Module reference errors     | Referencing resources directly           | Used module outputs                |
| EC2 outputs with ASG        | ASG instances are ephemeral              | Removed EC2 outputs                |
| HTTP timeout                | SG blocked port 80                       | Corrected SG rules                 |

---

# 🧠 Key Takeaways

* Terraform **will punish bad design** — and that’s good
* Modules must have **clear contracts**
* Over-parameterization is a beginner mistake
* ASG changes how you think about servers
* Destroying infra is not scary when Terraform is correct

---

# 🚀 Final Statement (Resume / Interview Ready)

> “I built a modular, multi-AZ, auto-scaling AWS infrastructure using Terraform with remote state, ALB, ASG, and immutable instances, and validated it by fully destroying and rebuilding the environment.”
