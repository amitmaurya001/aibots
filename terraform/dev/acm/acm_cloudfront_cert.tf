module "acm_cloudfront_cert" {
  source = "../../modules/acm"

  providers = {
    aws = aws.nv
  }

  account_id = var.account_id
  env        = var.env
  project    = var.project
  region     = var.region

  cert_name = "cf_cert"

  cert = {
    main = {
      name = "amitwebsite.online"
      zone = "amitwebsite.online"
    }
    sans = []
  }
}
