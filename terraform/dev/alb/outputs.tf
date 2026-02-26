output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "listener_443_arn" {
  value = module.alb.listener_443_arn
}

output "arn_suffix" {
  value = module.alb.arn_suffix
}