
#tfsec:ignore:aws-s3-enable-bucket-encryption:tfsec is yet not detecting the aws_s3_bucket_server_side_encryption_configuration resource block. https://github.com/aquasecurity/defsec/issues/489
#tfsec:ignore:aws-s3-enable-bucket-logging tfsec:ignore:aws-s3-enable-versioning
resource "aws_s3_bucket" "new_bucket" {
  bucket = var.bucket_name

  force_destroy = var.force_destroy
  tags          = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_for_new_bucket" {
  bucket = aws_s3_bucket.new_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bucket policy to enforce AES256 server-side-encryption
resource "aws_s3_bucket_policy" "sse_bucket_policy" {
  bucket = aws_s3_bucket.new_bucket.id
  policy = templatefile(
    "${path.module}/bucket-policy.json",
    {
      bucket_name   = aws_s3_bucket.new_bucket.id,
      arn_partition = var.arn_partition
    }
  )
}

# Sets S3 bucket ACL
resource "aws_s3_bucket_acl" "acl_for_new_bucket" {
  bucket = aws_s3_bucket.new_bucket.id
  acl    = "private"
}

# Enabling S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "for_new_bucket" {
  bucket = aws_s3_bucket.new_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
