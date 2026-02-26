resource "aws_s3_bucket" "waf_logs" {
  provider = aws.nv

  bucket = "${var.name_prefix}-waf-logs-${var.account_id}"

  force_destroy = false
  tags          = var.common_tags

  lifecycle {
    ignore_changes = [
      server_side_encryption_configuration,
      lifecycle_rule,
    ]
  }
}

resource "aws_s3_bucket_public_access_block" "waf_logs" {
  provider = aws.nv
  bucket   = aws_s3_bucket.waf_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "waf_logs" {
  provider = aws.nv

  bucket = aws_s3_bucket.waf_logs.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "waf_logs" {
  provider = aws.nv

  bucket = aws_s3_bucket.waf_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "waf_logs" {
  provider = aws.nv

  bucket = aws_s3_bucket.waf_logs.bucket

  rule {
    id     = "delete"
    status = "Enabled"
    filter {}

    expiration {
      days = 30
    }
  }
}

resource "aws_iam_role" "firehose" {
  name = "${var.name_prefix}-firehose-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "firehose001"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "firehose_s3_access" {
  name = "${var.name_prefix}-firehose-s3-access"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:AbortMultipartUpload",
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:PutObject"
            ],
            "Resource": [
                "${aws_s3_bucket.waf_logs.arn}",
                "${aws_s3_bucket.waf_logs.arn}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "firehose_attach_firehose_s3_access" {
  role       = aws_iam_role.firehose.name
  policy_arn = aws_iam_policy.firehose_s3_access.arn
}

resource "aws_iam_policy" "firehose_lambda_invoke" {
  name = "${var.name_prefix}-firehose-lambda-invoke"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction",
                "lambda:GetFunctionConfiguration"
            ],
            "Resource": [
                "${aws_lambda_function.waf_firehose_handler.arn}:*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "firehose_attach_firehose_firehose_lambda_invoke" {
  role       = aws_iam_role.firehose.name
  policy_arn = aws_iam_policy.firehose_lambda_invoke.arn
}

resource "aws_kinesis_firehose_delivery_stream" "waf_stream" {
  provider    = aws.nv
  name        = "aws-waf-logs-${var.name_prefix}-waf"
  destination = "extended_s3"

  extended_s3_configuration {
    compression_format = "GZIP"
    buffering_interval = 180
    buffering_size     = 128
    role_arn           = aws_iam_role.firehose.arn
    bucket_arn         = aws_s3_bucket.waf_logs.arn

    processing_configuration {
      enabled = "true"

      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${aws_lambda_function.waf_firehose_handler.arn}:$LATEST"
        }
      }
    }
  }
}

resource "aws_wafv2_web_acl_logging_configuration" "log_configuration" {
  provider = aws.nv

  log_destination_configs = [
    aws_kinesis_firehose_delivery_stream.waf_stream.arn
  ]

  resource_arn = aws_wafv2_web_acl.aws_managed_webacl.arn
}
