data "aws_route53_zone" "apex" {
  for_each = var.apex_domains

  name = each.key
}

data "aws_canonical_user_id" "current" {}

data "aws_sns_topic" "alarm_topic_nv" {
  provider = aws.nv

  name = var.alarm_sns_topic_name
}
