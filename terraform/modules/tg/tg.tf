resource "aws_lb_target_group" "this" {
  name     = format("%s-%s", local.name_prefix, var.tg_name)
  port     = var.tg_port
  protocol = var.tg_protocol
  vpc_id   = var.vpc_id

  deregistration_delay = var.deregistration_delay

  stickiness {
    enabled = var.stickiness_enabled

    # Due to missing a new ALB TG stickiness type "app_cookie" required by the app;
    # for now being changed manually - to be retrofitted once added by AWS Terraform provider developers
    type            = "lb_cookie"
    cookie_duration = var.stickiness_cookie_duration
  }

  health_check {
    port                = var.health_check_port
    protocol            = var.health_check_protocol
    enabled             = var.health_check_enabled
    interval            = var.health_check_interval
    path                = var.health_check_path
    timeout             = var.health_check_timeout
    healthy_threshold   = var.health_check_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    matcher             = var.health_check_matcher
  }

  lifecycle {
    # Due to missing a new ALB TG stickiness type "app_cookie" required by the app;
    # for now being changed manually - to be retrofitted once added by AWS Terraform provider developers
    ignore_changes = [stickiness]
  }
}

resource "aws_lb_target_group_attachment" "instances" {
  count = length(var.instance_ids)

  target_group_arn = aws_lb_target_group.this.arn
  target_id        = element(var.instance_ids, count.index)
  port             = var.instance_port
}

resource "aws_lb_listener_rule" "host" {
  listener_arn = var.listener_443_arn
  priority     = 3

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    host_header {
      values = var.host_headers
    }
  }
}
