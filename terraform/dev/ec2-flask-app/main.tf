terraform {
  backend "s3" {
    bucket         = "terraform-state-ai-bots"
    dynamodb_table = "terraform-state-ai-bots"
    encrypt        = true
    key            = "dev-flask-app.tfstate"
    region         = "eu-central-1"
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "terraform-state-ai-bots"
    key    = "dev-network.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "alb" {
  backend = "s3"

  config = {
    bucket = "terraform-state-ai-bots"
    key    = "dev-alb.tfstate"
    region = var.region
  }
}

provider "aws" {
  allowed_account_ids = [var.account_id]
  region              = var.region
}
