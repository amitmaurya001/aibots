resource "aws_cloudwatch_metric_alarm" "error_rate_5xx_apex" {
  for_each = aws_cloudfront_distribution.apex_distribution

  provider = aws.nv

  alarm_name = format("%s-Cloudfront-5xx-rate-%s", var.name_prefix, each.key)

  namespace           = "AWS/CloudFront"
  metric_name         = "5xxErrorRate"
  statistic           = "Average"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 25
  datapoints_to_alarm = 1
  evaluation_periods  = 3
  period              = 300
  treat_missing_data  = "notBreaching"

  dimensions = {
    Region         = "Global"
    DistributionId = each.value.id
  }

  alarm_actions = [data.aws_sns_topic.alarm_topic_nv.arn]
}
