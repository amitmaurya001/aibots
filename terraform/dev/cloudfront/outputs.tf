output "cf_logs_bucket_arn" {
  value = module.cloudfront.cf_logs_bucket_arn
}

output "distribution_arns" {
  value = module.cloudfront.distribution_arns
}
