output "vpc" {
  value = module.network.vpc
}

output "subnets_private" {
  value = module.network.subnets_private
}

output "subnets_public" {
  value = module.network.subnets_public
}

output "sg_alb" {
  value = module.network.sg_alb
}

output "sg_app" {
  value = module.network.sg_app
}

