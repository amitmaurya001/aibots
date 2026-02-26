resource "aws_cloudfront_cache_policy" "s3_origin" {
  name        = "s3-origin-cache-policy"
  comment     = "s3-origin-cache-policy"
  default_ttl = 2592000
  max_ttl     = 2592000
  min_ttl     = 2592000

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "whitelist"
      headers {
        items = [
          "X-TEST",
        ]
      }
    }

    query_strings_config {
      query_string_behavior = "none"
    }

    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
  }
}

resource "aws_cloudfront_cache_policy" "css_and_js" {
  name        = "css-and-js-cache-policy"
  comment     = "css-and-js-cache-policy"
  default_ttl = 2592000
  max_ttl     = 2592000
  min_ttl     = 2592000

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "whitelist"
      headers {
        items = [
          "X-TEST",
        ]
      }
    }

    query_strings_config {
      query_string_behavior = "all"
    }

    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
  }
}

resource "aws_cloudfront_cache_policy" "images_and_pdf" {
  name        = "images-and-pdf-cache-policy"
  comment     = "images-and-pdf-cache-policy"
  default_ttl = 2592000
  max_ttl     = 2592000
  min_ttl     = 2592000

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "whitelist"
      headers {
        items = [
          "X-TEST",
        ]
      }
    }

    query_strings_config {
      query_string_behavior = "none"
    }

    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
  }
}

resource "aws_cloudfront_cache_policy" "static_landing_page" {
  name        = "static-landing-page-cache-policy"
  comment     = "static-landing-page-cache-policy"
  default_ttl = 1209600
  max_ttl     = 31536000
  min_ttl     = 1209600

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "whitelist"
      cookies {
        items = ["JWT"]
      }
    }

    headers_config {
      header_behavior = "whitelist"
      headers {
        items = [
          "X-TEST",
        ]
      }
    }

    query_strings_config {
      query_string_behavior = "all"
    }

    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
  }
}

resource "aws_cloudfront_cache_policy" "static_landing_page_with_bot_key" {
  name        = "static-landing-page-with-bot-key"
  comment     = "Like static_landing_page, but cache key varies by X-Bot and longer cache time"
  default_ttl = 2592000 # 30d
  max_ttl     = 2592000
  min_ttl     = 2592000

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "whitelist"
      cookies { items = ["JWT"] }
    }

    headers_config {
      header_behavior = "whitelist"
      headers {
        # bot headers for debugging and cache split
        items = ["X-TEST-BOT", "X-Bot"]
      }
    }

    query_strings_config { query_string_behavior = "all" }

    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
  }
}
