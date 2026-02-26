resource "aws_cloudwatch_log_group" "flask" {
  name              = local.app_name_full
  retention_in_days = "30"
}
