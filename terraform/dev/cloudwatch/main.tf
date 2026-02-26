terraform {
  backend "s3" {
    bucket         = "terraform-state-ai-bots"
    dynamodb_table = "terraform-state-ai-bots"
    encrypt        = true
    key            = "dev-cloudwatch.tfstate"
    region         = "eu-central-1"
  }
}

provider "aws" {
  allowed_account_ids = [var.account_id]
  region              = var.region
}

module "cloudwatch" {
  source = "../../modules/cloudwatch"

  account_id           = var.account_id
  env                  = var.env
  project              = var.project
  region               = var.region
  log_streams          = [""]
  app_name             = "flask"
}
