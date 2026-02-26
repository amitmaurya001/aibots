terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.13"
    }
  }

  required_version = "~> 1.13"
}

provider "aws" {
  default_tags {
    tags = local.common_tags
  }
  region = var.region
}
