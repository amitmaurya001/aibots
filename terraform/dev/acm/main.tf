terraform {
  backend "s3" {
    bucket         = "terraform-state-ai-bots-amit"
    dynamodb_table = "terraform-state-ai-bots-amit"
    encrypt        = true
    key            = "dev-acm-cert.tfstate"
    region         = "us-east-1"
  }
}

provider "aws" {
  allowed_account_ids = [var.account_id]
  region              = var.region

  default_tags {
    tags = local.common_tags
  }
}

provider "aws" {
  alias               = "nv"
  allowed_account_ids = [var.account_id]
  region              = "us-east-1"

  default_tags {
    tags = local.common_tags
  }
}
