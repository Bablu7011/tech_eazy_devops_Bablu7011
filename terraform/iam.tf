# This policy defines the permissions for our EC2 role.
# It allows creating the bucket and uploading objects, but not reading them.
resource "aws_iam_policy" "s3_upload_policy" {
  name        = "${var.stage}-s3-upload-policy"
  description = "Allows creating bucket and uploading logs to S3"

  # The actual permissions in JSON format
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:PutObject" # Allows uploading files
        ]
        # This applies the permission to all objects INSIDE the bucket
        Resource = "arn:aws:s3:::${var.s3_bucket_name}/*"
      }
    ]
  })
}

# This is the IAM Role that our EC2 instance will "assume" or use.
resource "aws_iam_role" "ec2_s3_uploader_role" {
  name = "${var.stage}-ec2-s3-uploader-role"

  # This "trust policy" specifies WHO can use this role.
  # In this case, we are trusting the EC2 service.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# This connects our Policy (the rules) to our Role (the keycard).
resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.ec2_s3_uploader_role.name
  policy_arn = aws_iam_policy.s3_upload_policy.arn
}

# This is the instance profile, which is the final container
# that we attach directly to the EC2 instance.
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.stage}-ec2-profile"
  role = aws_iam_role.ec2_s3_uploader_role.name
}




# This policy allows only listing the contents of the S3 bucket.
resource "aws_iam_policy" "s3_read_only_policy" {
  name        = "${var.stage}-s3-read-only-policy"
  description = "Allows listing objects in the S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = "arn:aws:s3:::${var.s3_bucket_name}"
      }
    ]
  })
}

# This is the Auditor Role.
# It trusts your AWS account, allowing you to assume it for verification.
resource "aws_iam_role" "s3_auditor_role" {
  name = "${var.stage}-s3-auditor-role"

  # The trust policy is different here. It's not for EC2, it's for your user account.
  # This requires your AWS Account ID. We'll fetch it automatically.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          # This line automatically gets your AWS Account ID.
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      }
    ]
  })
}

# This attaches the read-only policy to the auditor role.
resource "aws_iam_role_policy_attachment" "attach_s3_read_policy" {
  role       = aws_iam_role.s3_auditor_role.name
  policy_arn = aws_iam_policy.s3_read_only_policy.arn
}

# This data source is needed to get your AWS Account ID automatically.
data "aws_caller_identity" "current" {}