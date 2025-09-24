
resource "aws_s3_bucket" "log_bucket" {
  bucket = var.s3_bucket_name
  
  # I added this to allow deletion of the bucket even if it contains objects.
  # Be cautious with this in production environments.
  force_destroy = true
  
  #
  tags = {
    Name  = "${var.stage}-log-bucket"
    Stage = var.stage
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "log_bucket_lifecycle" {
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    id     = "delete-logs-after-7-days"
    status = "Enabled"

    expiration {
      days = 7
    }

    # This rule applies to all objects in the bucket.
    filter {}
  }
}