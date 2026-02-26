# S3 bucket that stores /<prefix>/... content
resource "aws_s3_bucket" "bot_origin" {
  bucket = local.bot_bucket_name
}

# OAI for secondary CF
resource "aws_cloudfront_origin_access_identity" "bot_oai" {
  comment = "OAI for ${local.bot_bucket_name}"
}

# Allow secondary CF to read from the bucket
data "aws_iam_policy_document" "bot_bucket_policy" {
  statement {
    sid       = "AllowCFGetObject"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.bot_origin.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.bot_oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "bot_origin" {
  bucket = aws_s3_bucket.bot_origin.id
  policy = data.aws_iam_policy_document.bot_bucket_policy.json
}

# Secondary CF (no aliases)
resource "aws_cloudfront_distribution" "bot_cdn" {
  comment         = "${var.name_prefix} bot CDN (CF->S3)"
  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_100"

  origin {
    domain_name = aws_s3_bucket.bot_origin.bucket_regional_domain_name
    origin_id   = "S3-${local.bot_bucket_name}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.bot_oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    target_origin_id         = "S3-${local.bot_bucket_name}"
    viewer_protocol_policy   = "redirect-to-https"
    allowed_methods          = ["GET", "HEAD", "OPTIONS"]
    cached_methods           = ["GET", "HEAD", "OPTIONS"]
    cache_policy_id          = aws_cloudfront_cache_policy.s3_origin.id
    origin_request_policy_id = local.AWS-Origin-Request-Managed-CORS-S3Origin-Policy
    compress                 = true
  }

  # Prefix behaviors: /cpm/*, /website/*, ...
  dynamic "ordered_cache_behavior" {
    for_each = var.bot_prefixes
    iterator = p

    content {
      path_pattern           = "/${p.value}/*"
      target_origin_id       = "S3-${local.bot_bucket_name}"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods        = ["GET", "HEAD", "OPTIONS"]
      cached_methods         = ["GET", "HEAD", "OPTIONS"]

      # your custom long-TTL cache policy
      cache_policy_id          = aws_cloudfront_cache_policy.s3_origin.id
      origin_request_policy_id = local.AWS-Origin-Request-Managed-CORS-S3Origin-Policy

      # reuse the already-created per-domain response headers policy
      response_headers_policy_id = aws_cloudfront_response_headers_policy.apex_from_s3[
        local.prefix_to_domain[p.value]
      ].id

      compress = true
    }
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
