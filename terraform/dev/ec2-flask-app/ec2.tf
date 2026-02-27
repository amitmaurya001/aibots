module "ec2" {
  source = "../../modules/ec2-single"

  account_id = var.account_id
  env        = var.env
  project    = var.project
  region     = var.region

  volume_size       = 12
  key_name          = "devsecops"
  instance_type     = "t3.small"
  az                = "us-east-1a"
  image_id          = "ami-0b6c6ebed2801a5cb" # raw ubuntu 24.04 LTS
  app_name          = "flask"

  sg      = data.terraform_remote_state.network.outputs.sg_app
  subnets = data.terraform_remote_state.network.outputs.subnets_public

  tg_arn = module.target_group.tg_arn

  alarm_sns_topic_name = "udemy-dev-alerts"
}
