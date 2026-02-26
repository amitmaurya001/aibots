resource "aws_route53_record" "apex" {
  for_each = aws_cloudfront_distribution.apex_distribution

  zone_id = data.aws_route53_zone.apex[each.key].id
  name    = each.key
  type    = "A"

  alias {
    name                   = each.value.domain_name
    zone_id                = each.value.hosted_zone_id
    evaluate_target_health = false
  }

  allow_overwrite = true
}
