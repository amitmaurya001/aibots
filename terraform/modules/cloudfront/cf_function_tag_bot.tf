resource "aws_cloudfront_function" "tag_bot" {
  name    = "${var.name_prefix}-tag-bot"
  runtime = "cloudfront-js-2.0"
  publish = true
  comment = "Sets X-CT-Bot: 1/0 for cache key separation"

  code = templatefile("${path.module}/templates/tag-bot.tmpl.js", {
    bot_user_agent_pattern = var.bot_user_agent_pattern
  })
}