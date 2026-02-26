resource "aws_cloudfront_response_headers_policy" "add-cache-control-header-1day" {
  name = "add-cache-control-header-1day"

  custom_headers_config {
    items {
      header   = "cache-control"
      override = true
      value    = "max-age=86400"
    }
  }

  server_timing_headers_config {
    enabled       = var.server_timing_enable
    sampling_rate = var.server_timing_sampling_rate
  }
}

resource "aws_cloudfront_response_headers_policy" "add-cache-control-header-2weeks" {
  name = "add-cache-control-header-2weeks"

  custom_headers_config {
    items {
      header   = "cache-control"
      override = true
      value    = "private"
    }
  }

  server_timing_headers_config {
    enabled       = var.server_timing_enable
    sampling_rate = var.server_timing_sampling_rate
  }
}

resource "aws_cloudfront_response_headers_policy" "add-cache-control-header-1month" {
  name = "add-cache-control-header-1month"

  custom_headers_config {
    items {
      header   = "cache-control"
      override = true
      value    = "max-age=2629800"
    }
  }

  server_timing_headers_config {
    enabled       = var.server_timing_enable
    sampling_rate = var.server_timing_sampling_rate
  }
}

resource "aws_cloudfront_response_headers_policy" "cors-and-cache-control-header-1month" {
  name = "cors-and-cache-control-header-1month"

  custom_headers_config {
    items {
      header   = "cache-control"
      override = true
      value    = "max-age=2629800"
    }
  }

  cors_config {
    access_control_allow_headers {
      items = ["*"]
    }

    access_control_allow_methods {
      items = ["GET", "HEAD", "OPTIONS"]
    }

    access_control_allow_origins {
      items = ["*"]
    }

    access_control_expose_headers {
      items = ["ETag"]
    }

    access_control_allow_credentials = false
    origin_override                  = true
  }

  server_timing_headers_config {
    enabled       = var.server_timing_enable
    sampling_rate = var.server_timing_sampling_rate
  }
}

resource "aws_cloudfront_response_headers_policy" "apex_from_s3" {
  for_each = var.apex_domains

  name = "apex_from_s3_${each.value["s3_origin_bucket_name"]}"

  custom_headers_config {
    items {
      header   = "Content-Language"
      override = true
      value    = each.value["content_language"]
    }

    items {
      header   = "Server"
      override = true
      value    = "nginx"
    }
  }

  security_headers_config {
    content_security_policy {
      override = true

      content_security_policy = "frame-ancestors 'self';"
    }

    content_type_options {
      override = true
    }

    referrer_policy {
      override = true

      referrer_policy = "strict-origin-when-cross-origin"
    }

    strict_transport_security {
      override = true

      access_control_max_age_sec = 31536001
      include_subdomains         = true
      preload                    = true
    }

    frame_options {
      override = true

      frame_option = "SAMEORIGIN"
    }
  }

  server_timing_headers_config {
    enabled       = var.server_timing_enable
    sampling_rate = var.server_timing_sampling_rate
  }
}
