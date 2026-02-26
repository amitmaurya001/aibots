resource "aws_s3_bucket" "apex_origin" {
  for_each = var.apex_domains

  bucket = format("%s-%s",
    var.name_prefix,
    each.value["s3_origin_bucket_name"],
  )

  lifecycle {
    ignore_changes = [
      server_side_encryption_configuration,
    ]
  }
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "access-identity-${var.name_prefix}-static-content.s3.amazonaws.com" # todo: rename?
}

data "aws_iam_policy_document" "s3_policy" {
  for_each = var.apex_domains

  policy_id = "PolicyForCloudFrontPrivateContent"

  statement {
    actions = ["s3:GetObject"]
    effect  = "Allow"

    resources = [
      "${aws_s3_bucket.apex_origin[each.key].arn}/*"
    ]

    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn
      ]
    }
    sid = "1"
  }
}

resource "aws_s3_bucket_policy" "origin_access_identity" {
  for_each = var.apex_domains

  bucket = aws_s3_bucket.apex_origin[each.key].id
  policy = data.aws_iam_policy_document.s3_policy[each.key].json
}
