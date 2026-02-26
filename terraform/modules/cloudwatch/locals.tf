locals {
  name_prefix = format("%s-%s", var.project, var.env)
  app_name_full = "${var.project}-${var.env}-${var.app_name}"

  common_tags = {
    Env       = var.env
    ManagedBy = "terraform"
    Project   = var.project
  }
}
