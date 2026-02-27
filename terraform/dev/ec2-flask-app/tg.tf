module "target_group" {
  source = "../../modules/tg"

  account_id = var.account_id
  env        = var.env
  project    = var.project
  region     = var.region
  vpc_id     = data.terraform_remote_state.network.outputs.vpc["id"]

  tg_name     = "flask"
  tg_port     = 80
  tg_protocol = "HTTP"

  listener_443_arn = data.terraform_remote_state.alb.outputs["listener_443_arn"]
  alb_dns_name     = data.terraform_remote_state.alb.outputs["alb_dns_name"]

  host_headers = [
    "flask.amitwebsite.online"
  ]

  deregistration_delay = 60

  instance_port = 80

  stickiness_enabled         = true
  stickiness_cookie_duration = 604800

  health_check_enabled             = true
  health_check_port                = 80
  health_check_protocol            = "HTTP"
  health_check_path                = "/ping"
  health_check_matcher             = "200-399"
  health_check_interval            = 60
  health_check_timeout             = 5
  health_check_threshold           = 2
  health_check_unhealthy_threshold = 2

  alb_arn_suffix       = data.terraform_remote_state.alb.outputs["arn_suffix"]
  alarm_sns_topic_name = "udemy-dev-alerts"

}
