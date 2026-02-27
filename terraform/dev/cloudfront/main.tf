locals {
  name_prefix = format("%s-%s", var.project, var.env)
  common_tags = {
    Env       = var.env
    ManagedBy = "terraform"
    Project   = var.project
  }
}

terraform {
  backend "s3" {
    bucket         = "terraform-state-ai-bots-amit"
    dynamodb_table = "terraform-state-ai-bots-amit"
    encrypt        = true
    key            = "dev-cloudfront.tfstate"
    region         = "us-east-1"
  }
}

data "terraform_remote_state" "alb" {
  backend = "s3"

  config = {
    bucket = "terraform-state-ai-bots-amit"
    key    = "dev-alb.tfstate"
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

provider "aws" {
  allowed_account_ids = [var.account_id]
  region              = var.region

  default_tags {
    tags = local.common_tags
  }
}

# Required: CloudFront, WAF, Lambda@Edge, and Firehose must all live in us-east-1.
# The cloudfront module uses this alias internally (provider = aws.nv).
provider "aws" {
  alias               = "nv"
  allowed_account_ids = [var.account_id]
  region              = "us-east-1"

  default_tags {
    tags = local.common_tags
  }
}

module "cloudfront" {
  source = "../../modules/cloudfront"

  # Pass the us-east-1 provider alias into the module so it can deploy
  # WAF, Lambda@Edge, Firehose, and related resources in the correct region.
  providers = {
    aws.nv = aws.nv
  }

  account_id = var.account_id
  env        = var.env
  project    = var.project
  region     = var.region

  apex_domains = {
    "amitwebsite.online" = {
      alb_dns_name          = data.terraform_remote_state.alb.outputs.alb_dns_name,
      s3_origin_bucket_name = "static-content-website"
      content_language      = "en_GB"
      static_paths          = ["/test", "/test/*"]
      cert_arn              = data.terraform_remote_state.acm.outputs.certs_arns["cf_cert"]
    }
  }

  bot_forwarding_domains = toset([
    "amitwebsite.online"
  ])
  bot_user_agent_pattern = "testbot|udemybot"
  # bot_user_agent_pattern = "gptbot|Gemini|SemrushBot|Qwantbot|msnbot|AwarioBot|AhrefsBot|YandexBot|DataForSeoBot|Exabot|HaloBot|petalbot|Amazonbot|Applebot|IbouBot|ClaudeBot|serpstatbot|mj12bot|SeekportBot|PerplexityBot|testbot"
  bot_prefixes = ["website"]

  name_prefix = local.name_prefix

  ips_to_be_allowed = ["x.x.x.x/32"]

  alarm_sns_topic_name = "udemy-dev-alerts"
  common_tags          = local.common_tags

  force_destroy_logs_bucket = true

  server_timing_enable        = true
  server_timing_sampling_rate = 100

  waf_rules_override_action = "none"
}
