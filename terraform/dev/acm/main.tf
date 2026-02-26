terraform {
  backend "s3" {
    bucket         = "terraform-state-ai-bots"
    dynamodb_table = "terraform-state-ai-bots"
    encrypt        = true
    key            = "dev-acm-cert.tfstate"
    region         = "eu-central-1"
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
