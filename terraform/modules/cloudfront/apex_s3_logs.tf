resource "aws_s3_bucket" "cf_logs" {
  provider = aws.nv

  bucket = "${var.name_prefix}-cloudfront-logs-${var.account_id}"

  force_destroy = var.force_destroy_logs_bucket

  lifecycle {
    ignore_changes = [
      server_side_encryption_configuration,
      lifecycle_rule,
      grant,
    ]
  }
}

resource "aws_s3_bucket_public_access_block" "cf_logs" {
  provider = aws.nv
  bucket   = aws_s3_bucket.cf_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "cf_logs" {
  provider = aws.nv
  bucket   = aws_s3_bucket.cf_logs.bucket

  depends_on = [
    aws_s3_bucket_ownership_controls.cf_logs
  ]

  access_control_policy {
    grant {
      grantee {
        type = "CanonicalUser"
        id   = "c4c1ede66af53448b93c283ce9448c4ba468c9432aa01d700d3878632f77d2d0" ###  awslogsdelivery
      }
      permission = "FULL_CONTROL"
    }

    owner {
      id = data.aws_canonical_user_id.current.id
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "cf_logs" {
  provider = aws.nv

  bucket = aws_s3_bucket.cf_logs.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cf_logs" {
  provider = aws.nv

  bucket = aws_s3_bucket.cf_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cf_logs" {
  provider = aws.nv

  bucket = aws_s3_bucket.cf_logs.bucket

  rule {
    id     = "delete"
    status = "Enabled"
    filter {}

    expiration {
      days = 60
    }
  }
}
