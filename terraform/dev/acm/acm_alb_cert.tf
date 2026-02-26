module "acm_alb_cert" {
  source = "../../modules/acm"

  account_id = var.account_id
  env        = var.env
  project    = var.project
  region     = var.region

  cert_name = "alb_cert"

  cert = {
    main = {
      name = "amitwebsite.online"
      zone = "amitwebsite.online"
    }
    sans = [
      {
        name = "*.amitwebsite.online"
        zone = "amitwebsite.online"
      }
    ]
  }
}
