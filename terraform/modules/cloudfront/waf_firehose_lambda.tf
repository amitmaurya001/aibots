data "aws_iam_policy_document" "only_lambda" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
  }
}

data "archive_file" "waf_firehose_handler" {
  type        = "zip"
  output_path = "/tmp/waf_firehose_handler.zip"

  source {
    content  = file("${path.module}/templates/waf_firehose_handler.py")
    filename = "waf_firehose_handler.py"
  }
}

resource "aws_lambda_function" "waf_firehose_handler" {
  provider = aws.nv

  function_name    = "${var.name_prefix}-waf-firehose-handler"
  role             = aws_iam_role.waf_firehose_handler.arn
  filename         = data.archive_file.waf_firehose_handler.output_path
  source_code_hash = data.archive_file.waf_firehose_handler.output_base64sha256
  handler          = "waf_firehose_handler.lambda_handler"
  runtime          = "python3.11"
  timeout          = 900
  memory_size      = 256

  environment {
    variables = {
      REGION = "${var.region}"
    }
  }
}

resource "aws_cloudwatch_log_group" "waf_firehose_handler" {
  provider = aws.nv

  name              = "/aws/lambda/${aws_lambda_function.waf_firehose_handler.function_name}"
  retention_in_days = 7
}

resource "aws_iam_role" "waf_firehose_handler" {
  name               = "${var.name_prefix}-waf-firehose-handler"
  assume_role_policy = data.aws_iam_policy_document.only_lambda.json
}

resource "aws_iam_role_policy_attachment" "waf_firehose_handler_attach_lambda_basic_execution" {
  role       = aws_iam_role.waf_firehose_handler.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
