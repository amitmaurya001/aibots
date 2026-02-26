### INSTANCE POLICY

data "aws_iam_policy_document" "common_instance_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "single_instance" {
  name_prefix        = "${local.name_prefix}-${var.app_name}-"
  assume_role_policy = data.aws_iam_policy_document.common_instance_assume.json
}

resource "aws_iam_instance_profile" "single" {
  name_prefix = "${local.name_prefix}-${var.app_name}-"
  role        = aws_iam_role.single_instance.name
}


### ECR

data "aws_iam_policy_document" "ecr" {
  statement {
    sid = "Ecr01"

    actions = [
      "ecr:*",
    ]

    resources = [
      "arn:aws:ecr:${var.region}:${var.account_id}:repository/${local.app_name_full}",
    ]
  }

  statement {
    sid = "Ecr02"
    actions = [
      "ecr:GetAuthorizationToken",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "ecr" {
  name_prefix = "${local.name_prefix}-${var.app_name}-ecr-"
  policy      = data.aws_iam_policy_document.ecr.json
}

resource "aws_iam_role_policy_attachment" "ecr" {
  policy_arn = aws_iam_policy.ecr.arn
  role       = aws_iam_role.single_instance.name
}

### CloudWatch

data "aws_iam_policy_document" "cw" {
  statement {
    sid = "Ssm01"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup"
    ]

    resources = [
      "arn:aws:logs:${var.region}:${var.account_id}:log-group:${local.app_name_full}",
      "arn:aws:logs:${var.region}:${var.account_id}:log-group:${local.app_name_full}:*",
    ]
  }
}

resource "aws_iam_policy" "cw" {
  name_prefix = "${local.name_prefix}-${var.app_name}-cw-"
  policy      = data.aws_iam_policy_document.cw.json
}

resource "aws_iam_role_policy_attachment" "cw" {
  policy_arn = aws_iam_policy.cw.arn
  role       = aws_iam_role.single_instance.name
}
