terraform {
  backend "s3" {
    bucket         = "terraform-state-ai-bots-amit"
    dynamodb_table = "terraform-state-ai-bots-amit"
    encrypt        = true
    key            = "dev-alb.tfstate"
    region         = "us-east-1"
  }
}

provider "aws" {
  allowed_account_ids = [var.account_id]
  region              = var.region
}

provider "aws" {
  alias  = "nv"
  region = "us-east-1"
}

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "terraform-state-ai-bots-amit"
    key    = "dev-network.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "acm" {
  backend = "s3"

  config = {
    bucket = "terraform-state-ai-bots-amit"
    key    = "dev-acm-cert.tfstate"
    region = var.region
  }
}

module "alb" {
  source = "../../modules/alb"

  account_id = var.account_id
  env        = var.env
  project    = var.project
  region     = var.region

  vpc        = data.terraform_remote_state.network.outputs.vpc
  lb_subnets = data.terraform_remote_state.network.outputs.subnets_public

  lb_sg         = data.terraform_remote_state.network.outputs.sg_alb
  lb_ssl_policy = "ELBSecurityPolicy-2016-08"

  acm_main_arn = data.terraform_remote_state.acm.outputs.certs_arns["alb_cert"]

  logs_enabled    = true
  logs_prefix     = "dev-flask"
  logs_bucket     = "dev-lb-flask-logs-${var.account_id}"
  logs_expiration = 30

  alarm_sns_topic_name = "udemy-dev-alerts"
}
