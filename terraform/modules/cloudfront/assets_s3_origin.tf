resource "aws_s3_bucket" "assets_origin" {
  bucket = "${var.name_prefix}-assets"
}

resource "aws_cloudfront_origin_access_identity" "assets_oai" {
  comment = "OAI for ${var.name_prefix}-assets"
}

data "aws_iam_policy_document" "assets_bucket_policy" {
  statement {
    sid       = "AllowCFGetObject"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.assets_origin.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.assets_oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "assets_origin_policy" {
  bucket = aws_s3_bucket.assets_origin.id
  policy = data.aws_iam_policy_document.assets_bucket_policy.json
}

resource "aws_s3_bucket_lifecycle_configuration" "assets_retention" {
  bucket = aws_s3_bucket.assets_origin.id

  rule {
    id     = "expire-old-assets"
    status = "Enabled"

    expiration {
      days = 60
    }
  }
}

