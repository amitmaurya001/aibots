resource "aws_cloudwatch_metric_alarm" "group_in_service_instances" {
  alarm_name          = format("%s-%s-%s", local.name_prefix, var.app_name, "GroupInServiceInstances")
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 3
  threshold           = 1
  namespace   = "AWS/AutoScaling"
  metric_name = "GroupInServiceInstances"
  statistic   = "Maximum"
  period      = 60
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.single.name
  }
  alarm_actions = [data.aws_sns_topic.alarm_topic.arn]
}
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name          = format("%s-%s-%s", local.name_prefix, var.app_name, "CPUUtilization")
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  threshold           = var.cpu_alarm_threshold
  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"
  statistic   = "Average"
  period      = 60
  dimensions = {
    AutoScalingGroupName = format("%s-%s", local.name_prefix, var.app_name)
  }
  alarm_actions = [data.aws_sns_topic.alarm_topic.arn]
}

