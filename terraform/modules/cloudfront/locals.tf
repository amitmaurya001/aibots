locals {
  AWS-Origin-Request-Managed-AllViewer-Policy     = "216adef6-5c7f-47e4-b989-5492eafa07d3"
  AWS-Origin-Request-Managed-CORS-S3Origin-Policy = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"
  AWS-Cache-Managed-CachingDisabled               = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"

  enabled_bot_domains = {
    for k, v in var.apex_domains :
    k => v
    if contains(var.bot_forwarding_domains, k) && length(try(v.static_paths, [])) > 0
  }

  bot_bucket_name = coalesce(var.bot_bucket_name, "${var.name_prefix}-bot-static-content")

  prefix_to_domain = {
    for domain, cfg in var.apex_domains :
    replace(cfg.s3_origin_bucket_name, "static-content-", "") => domain
  }
}
