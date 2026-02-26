output "cf_logs_bucket_arn" {
  value = aws_s3_bucket.cf_logs.arn
}

output "distribution_arns" {
  value = concat(
    [for d in aws_cloudfront_distribution.apex_distribution : d.arn]
  )
}
