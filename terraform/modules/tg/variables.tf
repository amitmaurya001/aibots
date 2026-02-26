variable "tg_name" {
  type        = string
  description = "TG Name"
}

variable "tg_port" {
  type        = number
  description = "TG Port"
}

variable "tg_protocol" {
  type        = string
  description = "TG Protocol"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "deregistration_delay" {
  type        = number
  description = "TG deregistration delay. AWS default: 300"
}

variable "stickiness_enabled" {
  type        = bool
  description = "TG stickiness"
}

variable "stickiness_cookie_duration" {
  type        = number
  description = "TG cookie duration. AWS default: 86400"
}

variable "health_check_port" {
  type = number
}

variable "health_check_protocol" {
  type = string
}

variable "health_check_enabled" {
  type = bool
}

variable "health_check_interval" {
  type = number
}

variable "health_check_path" {
  type = string
}

variable "health_check_timeout" {
  type = number
}

variable "health_check_threshold" {
  type = number
}

variable "health_check_unhealthy_threshold" {
  type = number
}

variable "health_check_matcher" {
  type = string
}

variable "instance_ids" {
  type        = list(string)
  description = "Instances to register with the TG"
  default     = []
}

variable "instance_port" {
  type = number
}

variable "listener_443_arn" {
  type        = string
  description = "Listener for the TG (443)"
}

variable "host_headers" {
  type        = list(string)
  description = "Host headers for Listener rule"
}

variable "alb_dns_name" {
  type        = string
  description = "ALB dns name for Alias record"
}

variable "alb_arn_suffix" {
  type = string
}
variable "alarm_sns_topic_name" {
  type = string
}