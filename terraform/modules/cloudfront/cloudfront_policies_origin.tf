resource "aws_cloudfront_origin_request_policy" "css_and_js" {
  name    = "css-and-js-origin-request-policy"
  comment = "css-and-js-origin-request-policy"

  cookies_config {
    cookie_behavior = "all"
  }

  headers_config {
    header_behavior = "whitelist"

    headers {
      items = [
        "Host",
        "CloudFront-Viewer-JA4-Fingerprint"
      ]
    }
  }

  query_strings_config {
    query_string_behavior = "all"
  }
}

resource "aws_cloudfront_origin_request_policy" "images_and_pdf" {
  name    = "images-and-pdf-origin-request-policy"
  comment = "images-and-pdf-origin-request-policy"

  cookies_config {
    cookie_behavior = "all"
  }

  headers_config {
    header_behavior = "whitelist"

    headers {
      items = [
        "Host",
        "CloudFront-Viewer-JA4-Fingerprint"
      ]
    }
  }

  query_strings_config {
    query_string_behavior = "none"
  }
}

resource "aws_cloudfront_origin_request_policy" "all_viewer_with_ja4" {
  name    = "all-viewer-with-ja4"
  comment = "All viewer headers + CloudFront JA headers"

  cookies_config { cookie_behavior = "all" }
  query_strings_config { query_string_behavior = "all" }

  headers_config {
    # <-- key line
    header_behavior = "allViewerAndWhitelistCloudFront"

    # Whitelist the CloudFront-added headers you want
    headers {
      items = [
        "CloudFront-Viewer-JA4-Fingerprint",
      ]
    }
  }
}
