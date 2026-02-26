resource "aws_wafv2_web_acl" "aws_managed_webacl" {
  provider = aws.nv

  name        = "${var.name_prefix}-webacl"
  description = "WAFv2 AWS Managed Rules"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    sampled_requests_enabled   = true
    metric_name                = "${var.name_prefix}-webacl"
  }
}
