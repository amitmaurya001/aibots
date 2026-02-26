resource "aws_cloudwatch_metric_alarm" "waf_potential_attack" {
  provider = aws.nv

  alarm_name          = "${var.name_prefix}-WAF-potential-attack"
  alarm_description   = "This alarm is triggered when there is a high volume of requests to be blocked by WAF for some reason - it can signify a potential attack"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 4
  datapoints_to_alarm = 4
  threshold           = 3000

  namespace          = "AWS/WAFV2"
  metric_name        = "BlockedRequests"
  statistic          = "Sum"
  period             = 300
  treat_missing_data = "notBreaching"

  dimensions = {
    Rule   = "ALL"
    WebACL = aws_wafv2_web_acl.aws_managed_webacl.name
  }

  alarm_actions = [data.aws_sns_topic.alarm_topic_nv.arn]
}
