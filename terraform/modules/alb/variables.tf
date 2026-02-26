variable "vpc" {}

variable "lb_sg" {
  description = "The ALB security group"
}

variable "lb_subnets" {}

variable "logs_enabled" {
  description = "ALB app logging enabled"
  type        = bool
}

variable "logs_prefix" {
  description = "The ALB app logs prefix"
  type        = string
}

variable "logs_bucket" {
  type        = string
  description = "ALB Logs bucket name"
  default     = null
}

variable "logs_expiration" {
  type        = number
  description = "ALB Logs expiration (S3)"
}

variable "logs_bucket_force_destroy" {
  type        = bool
  default     = false
  description = "Force terraform destruction of the ALB Logs bucket?"
}

variable "lb_ssl_policy" {
  description = "The ALB ssl policy"
  type        = string
}

variable "alarm_sns_topic_name" {
  type = string
}

variable "acm_main_arn" {}

variable "alb_5xx_threshold" {
  type    = number
  default = 20
}

variable "target_5xx_threshold" {
  type    = number
  default = 20
}