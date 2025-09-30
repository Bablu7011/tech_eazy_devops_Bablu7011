variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami" {
  description = "Ubuntu 22.04 LTS AMI ID"
  type        = string
  # Ubuntu 22.04 LTS for ap-south-1, change for your region
  default     = "ami-0f5ee92e2d63afc18"
}

variable "key_name" {
  description = "Name of the SSH key pair in AWS"
  type        = string
}

variable "stage" {
  description = "Deployment stage (Dev/Prod)"
  type        = string
  default     = "Dev"
}

variable "s3_bucket_name" {
  description = "The globally unique name for the S3 bucket. Must be unique."
  type        = string
}