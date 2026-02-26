data "archive_file" "bot_cf_router_zip" {
  for_each    = local.enabled_bot_domains
  type        = "zip"
  output_path = "${path.module}/.artifacts/bot-cf-router-${replace(each.key, ".", "-")}.zip"
  source {
    filename = "index.py"
    content = templatefile("${path.module}/templates/bot-cf-router.tmpl.py", {
      target_cf_domain       = aws_cloudfront_distribution.bot_cdn.domain_name
      allowed_prefixes_json  = jsonencode(var.bot_prefixes) # list of allowed TLDs/prefixes
      bot_user_agent_pattern = var.bot_user_agent_pattern   # e.g. "testbot|udemybot"
    })
  }
}

resource "aws_iam_role" "bot_cf_router_role" {
  name = "${var.name_prefix}-bot-cf-router-edge"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = ["lambda.amazonaws.com", "edgelambda.amazonaws.com"] },
      Action    = "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_role_policy_attachment" "bot_cf_router_logs" {
  role       = aws_iam_role.bot_cf_router_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda@Edge in us-east-1
resource "aws_lambda_function" "bot_cf_router" {
  provider         = aws.nv
  for_each         = local.enabled_bot_domains
  function_name    = "${var.name_prefix}-bot-cf-router-${replace(each.key, ".", "-")}"
  role             = aws_iam_role.bot_cf_router_role.arn
  handler          = "index.handler"
  runtime          = "python3.11"
  filename         = data.archive_file.bot_cf_router_zip[each.key].output_path
  source_code_hash = data.archive_file.bot_cf_router_zip[each.key].output_base64sha256
  publish          = true
  memory_size      = 128
  timeout          = 1
}

resource "aws_lambda_permission" "allow_cf_router" {
  provider      = aws.nv
  for_each      = local.enabled_bot_domains
  statement_id  = "AllowCFExec-${replace(each.key, ".", "-")}"
  action        = "lambda:GetFunction"
  function_name = aws_lambda_function.bot_cf_router[each.key].function_name
  principal     = "edgelambda.amazonaws.com"
}
