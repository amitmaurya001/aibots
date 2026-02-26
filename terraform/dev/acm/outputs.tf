output "certs_arns" {
  value = {
    cf_cert    = module.acm_cloudfront_cert.cert.arn
    alb_cert   = module.acm_alb_cert.cert.arn
  }
}
