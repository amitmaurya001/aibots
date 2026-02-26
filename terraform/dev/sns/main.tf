terraform {
  backend "s3" {
    bucket         = "terraform-state-ai-bots"
    dynamodb_table = "terraform-state-ai-bots"
    encrypt        = true
    key            = "dev-sns.tfstate"
    region         = "eu-central-1"
  }
}

provider "aws" {
  allowed_account_ids = [var.account_id]
  region              = var.region
}

provider "aws" {
  alias               = "n-virginia"
  allowed_account_ids = [var.account_id]
  region              = "us-east-1"
}

module "sns_dev_alerts" {
  source = "../../modules/sns"

  account_id = var.account_id
  env        = var.env
  project    = var.project
  region     = var.region

  topic_name = "udemy-dev-alerts"

  subscriptions = {
    sergii = {
      protocol = "email"
      endpoint = "amitdostzzz@gmail.com"
    },
  }
}

module "sns_nv_dev_alerts" {
  source = "../../modules/sns"

  providers = {
    aws = aws.n-virginia
  }

  account_id = var.account_id
  env        = var.env
  project    = var.project
  region     = "us-east-1"

  topic_name = "udemy-dev-alerts"

  subscriptions = {
    sergii = {
      protocol = "email"
      endpoint = "sergiid.blog@gmail.com"
    },
  }
}
