# ☁️ DevOps Project – AWS Infrastructure Automation using Terraform

This project demonstrates a complete AWS automation pipeline — from provisioning EC2 instances to enabling CI/CD, Auto Scaling, and centralized logging — all using Terraform and GitHub Actions.

---

## 🚀 Assignment 1 – Automate EC2 Deployment

This project demonstrates how to automate the provisioning of an EC2 instance on AWS using Terraform.

### Steps to Deploy
1. **Configure AWS CLI**
   ```bash
   aws configure


Enter your AWS Access Key, Secret Key, Region, and Output format.

Create an SSH Key

ssh-keygen -t rsa -b 2048 -f ~/.ssh/mykey
aws ec2 import-key-pair --key-name "mykey" --public-key-material fileb://~/.ssh/mykey.pub


Set Environment Variable for Key Name

export TF_VAR_key_name="aws-key"


Deploy Infrastructure

cd terraform
terraform init
terraform apply -auto-approve


Get Public IP of EC2

terraform output ec2_public_ip


Test in Browser
Visit:

http://<PUBLIC_IP>


Destroy Resources

terraform destroy -auto-approve

📦 Assignment 2 – S3 Integration, IAM, and Logging

This assignment extends the EC2 deployment by integrating S3 for log archival and IAM roles for secure, keyless access.

🔑 Features Implemented

Secure S3 Bucket

Private S3 bucket for storing logs.

Configurable bucket name via Terraform variable.

IAM Roles (Least Privilege)

Uploader Role: Attached to EC2, only uploads logs.

Auditor Role: Read-only, used for verification.

Keyless EC2 → S3 Access

EC2 uses an IAM Instance Profile.

No AWS keys stored locally.

Automated Log Upload

user_data.sh starts the app and uploads logs to:

s3://<bucket-name>/app/logs


S3 Lifecycle Rule

Automatically deletes logs after 7 days.

Terraform Structure

main.tf → EC2 + Networking

iam.tf → IAM Roles

s3.tf → S3 + Lifecycle Rules

🔍 Verification (Auditor Role)

Used Switch Role in AWS Console → Dev-s3-auditor-role.

Verified logs via:

https://s3.console.aws.amazon.com/s3/buckets/<bucket-name>

⚙️ Assignment 3 – CI/CD with GitHub Actions, ELB, and Pull-Based Deployment Model

This phase builds a self-updating, scalable system with Load Balancer integration and CI/CD pipeline automation.

🏗️ New Architecture

Application Load Balancer (ELB):
Distributes traffic across multiple EC2 instances.

Multiple EC2 Instances:
Configurable via Terraform variable, auto-registered to Target Group.

S3 Buckets:

JAR Bucket (stores app builds)

EC2 Logs Bucket (collects logs per instance)

ELB Logs Bucket (stores ALB access logs)

🔄 Self-Updating Deployment

Each EC2 polls JAR S3 Bucket every 5 minutes.

If a new .jar file is found:

Old process stops.

New version runs automatically.

🧩 CI/CD Workflow

Triggered manually via workflow_dispatch in GitHub Actions.

Builds Java project with Maven.

Uploads new JAR to S3 bucket → EC2 auto-updates itself.

🔒 Security Enhancements

IAM Policies follow Principle of Least Privilege.

ELB has its own logging S3 bucket policy.

Auditor Role has read-only access to all buckets.

✅ Verification

Assume Auditor Role.

Visit:

https://s3.console.aws.amazon.com/s3/buckets/<your-bucket>


View:

jar/ → latest build

ec2-logs/ → instance logs

alb-logs/ → ALB access logs

🗑️ Cleanup
terraform destroy -auto-approve

📊 Assignment 4 – Auto Scaling, Monitoring, and Centralized Event Logging

This assignment focuses on dynamic scaling of infrastructure based on traffic and real-time event logging using CloudWatch, SNS, and Lambda.

🌐 Overview

Goal: Automatically scale EC2 instances based on ALB traffic and log every scaling event centrally.

Key Components:

CloudWatch Alarms

Auto Scaling Group (ASG)

SNS Notifications

Lambda Logging Function

CloudWatch Dashboards

🧠 Features Implemented

Auto Scaling Policies

Scale Up:
If ALB request count per target > 100 for 1 minute → add 1 instance.

Scale Down:
If ALB request count < 100 for 5 minutes → remove 1 instance.

Implemented using aws_autoscaling_policy + aws_cloudwatch_metric_alarm.

SNS Notifications

ASG sends lifecycle events (Launch/Terminate) to an SNS topic.

Topic has two subscribers:

Lambda function (for logging)

Email alerts for admin

Lambda for Event Logging

Function: dev-asg-log-writer

Triggered automatically via SNS.

Writes structured JSON logs to CloudWatch under:

/aws/autoscaling/dev-asg


Logs every EC2 scale event, including instance ID, cause, and policy name.

CloudWatch Dashboard

Displays key metrics:

ALB request count

Number of EC2 instances

Scaling activity (up/down events)

Helps visualize system behavior in real time.

IAM Roles & Permissions

Lambda role has fine-grained permissions:

logs:CreateLogGroup
logs:CreateLogStream
logs:PutLogEvents


Auto Scaling and CloudWatch integration via Terraform-managed roles.

Centralized Event Logging

Every scaling action is logged as:

🪶 Auto Scaling Event:
EC2 Instance i-xxxxxxxx launched due to high traffic.


Stored securely in CloudWatch Logs.

✅ Verification Steps

Trigger Scale Up

Increase ALB traffic >100 requests/min.

Verify:

New EC2 instance launched.

Log entry appears in /aws/autoscaling/dev-asg.

Trigger Scale Down

Let traffic fall <100 for 5 minutes.

Verify instance termination in logs.

Email Notification

Confirm scaling event emails received from SNS.

Dashboard

Check CloudWatch Dashboard for scaling history and instance count.

🧹 Cleanup

After validation, destroy the infrastructure to save cost:

terraform destroy -auto-approve