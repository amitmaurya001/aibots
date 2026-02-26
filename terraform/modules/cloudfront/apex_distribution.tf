resource "aws_cloudfront_distribution" "apex_distribution" {
  for_each = var.apex_domains

  comment = each.key

  origin {
    domain_name = each.value["alb_dns_name"]
    origin_id   = "ELB-${split(".", each.value["alb_dns_name"]).0}"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "match-viewer"
      origin_read_timeout      = 60

      origin_ssl_protocols = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2",
      ]
    }
  }

  origin {
    domain_name = aws_s3_bucket.apex_origin[each.key].bucket_regional_domain_name
    origin_id   = "S3-${var.name_prefix}-static-content"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  origin {
    domain_name = aws_s3_bucket.assets_origin.bucket_regional_domain_name
    origin_id   = "S3-${var.name_prefix}-assets"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.assets_oai.cloudfront_access_identity_path
    }
  }

  enabled         = true
  is_ipv6_enabled = true
  aliases         = [each.key]

  default_cache_behavior {
    cache_policy_id          = local.AWS-Cache-Managed-CachingDisabled
    origin_request_policy_id = aws_cloudfront_origin_request_policy.all_viewer_with_ja4.id
    cached_methods           = ["GET", "HEAD"]
    allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    target_origin_id         = "ELB-${split(".", each.value["alb_dns_name"]).0}"
    viewer_protocol_policy   = "redirect-to-https"
  }

  dynamic "ordered_cache_behavior" {
    for_each = each.value["static_paths"]
    iterator = path

    content {
      path_pattern = path.value

      # Use bot-split cache policy only for opted-in domains
      cache_policy_id = (
        contains(var.bot_forwarding_domains, each.key)
        ? aws_cloudfront_cache_policy.static_landing_page_with_bot_key.id
        : aws_cloudfront_cache_policy.static_landing_page.id
      )

      origin_request_policy_id = aws_cloudfront_origin_request_policy.all_viewer_with_ja4.id

      allowed_methods  = ["GET", "HEAD", "OPTIONS"]
      cached_methods   = ["GET", "HEAD", "OPTIONS"]
      target_origin_id = "ELB-${split(".", each.value["alb_dns_name"]).0}"

      compress               = true
      viewer_protocol_policy = "redirect-to-https"

      response_headers_policy_id = aws_cloudfront_response_headers_policy.add-cache-control-header-2weeks.id

      # Tag bot/human BEFORE cache lookup (viewer-request)
      dynamic "function_association" {
        for_each = contains(var.bot_forwarding_domains, each.key) ? [1] : []
        content {
          event_type   = "viewer-request"
          function_arn = aws_cloudfront_function.tag_bot.arn
        }
      }

      # Lambda that routes bots to the secondary CF
      dynamic "lambda_function_association" {
        for_each = contains(var.bot_forwarding_domains, each.key) ? [1] : []
        content {
          event_type   = "origin-request"
          lambda_arn   = aws_lambda_function.bot_cf_router[each.key].qualified_arn
          include_body = false
        }
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = ["*.png", "*.pdf"]
    iterator = path

    content {
      path_pattern             = path.value
      cache_policy_id          = aws_cloudfront_cache_policy.images_and_pdf.id
      origin_request_policy_id = aws_cloudfront_origin_request_policy.images_and_pdf.id

      allowed_methods  = ["GET", "HEAD", "OPTIONS"]
      cached_methods   = ["GET", "HEAD", "OPTIONS"]
      target_origin_id = "ELB-${split(".", each.value["alb_dns_name"]).0}"

      compress               = true
      viewer_protocol_policy = "redirect-to-https"

      response_headers_policy_id = aws_cloudfront_response_headers_policy.add-cache-control-header-1month.id
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = ["*.css", "*.js"]
    iterator = path

    content {
      path_pattern             = path.value
      cache_policy_id          = aws_cloudfront_cache_policy.css_and_js.id
      origin_request_policy_id = local.AWS-Origin-Request-Managed-CORS-S3Origin-Policy

      allowed_methods  = ["GET", "HEAD", "OPTIONS"]
      cached_methods   = ["GET", "HEAD", "OPTIONS"]
      target_origin_id = "S3-${var.name_prefix}-assets"

      compress               = true
      viewer_protocol_policy = "redirect-to-https"

      response_headers_policy_id = aws_cloudfront_response_headers_policy.cors-and-cache-control-header-1month.id
    }
  }

  ordered_cache_behavior {
    path_pattern             = "/maintenance.html"
    cache_policy_id          = aws_cloudfront_cache_policy.s3_origin.id
    origin_request_policy_id = local.AWS-Origin-Request-Managed-CORS-S3Origin-Policy

    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "S3-${var.name_prefix}-static-content"

    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    response_headers_policy_id = aws_cloudfront_response_headers_policy.apex_from_s3[each.key].id
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = each.value["cert_arn"]
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  web_acl_id = aws_wafv2_web_acl.aws_managed_webacl.arn

  logging_config {
    include_cookies = true
    bucket          = aws_s3_bucket.cf_logs.bucket_domain_name
  }

  depends_on = [
    aws_s3_bucket_ownership_controls.cf_logs
  ]

  tags = var.common_tags

  custom_error_response {
    error_code            = 503
    response_code         = 503
    response_page_path    = "/maintenance.html"
    error_caching_min_ttl = 60 # seconds to cache the 503
  }
}
