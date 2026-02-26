resource "aws_autoscaling_group" "single" {
  name = "${local.name_prefix}-${var.app_name}"

  min_size         = 1
  max_size         = 1
  desired_capacity = 1

  health_check_type         = "EC2"
  health_check_grace_period = 60 # default 300
  default_cooldown          = 300

  force_delete = true

  launch_template {
    id      = aws_launch_template.single.id
    version = "$Latest"
  }

  target_group_arns = [var.tg_arn]

  vpc_zone_identifier = var.subnets[*].id

  termination_policies = [
    "OldestLaunchTemplate",
    "OldestInstance",
    "ClosestToNextInstanceHour",
  ]

  dynamic "tag" {
    for_each = merge(local.common_tags, {
      Name = "${local.name_prefix}-${var.app_name}"
    })

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  metrics_granularity = "1Minute"
  enabled_metrics = [
    "GroupInServiceInstances"
  ]

  protect_from_scale_in = false
}
