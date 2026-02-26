provider "aws" {
  alias               = "nv"
  allowed_account_ids = [var.account_id]
  region              = "us-east-1"

  default_tags {
    tags = var.common_tags
  }
}
