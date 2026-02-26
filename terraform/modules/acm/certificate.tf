resource "aws_acm_certificate" "this" {
  domain_name       = var.cert.main.name
  validation_method = "DNS"

  subject_alternative_names = [for san in var.cert.sans : san.name]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = var.cert_name
  }
}

locals {
  names_zones = merge({
    (var.cert.main.name) = var.cert.main.zone
    }, {
    for san in var.cert.sans : san.name => san.zone
  })
}

data "aws_route53_zone" "this" {
  for_each = local.names_zones

  name = each.value
}

resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      domain_name = dvo.domain_name
      name        = dvo.resource_record_name
      record      = dvo.resource_record_value
      type        = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = data.aws_route53_zone.this[each.value.domain_name].id
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}
