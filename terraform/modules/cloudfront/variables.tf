variable "apex_domains" {}

variable "name_prefix" {}

variable "common_tags" {}

variable "ips_to_be_allowed" {}

variable "alarm_sns_topic_name" {}

variable "server_timing_enable" {
  type    = bool
  default = false
}
variable "server_timing_sampling_rate" {
  type    = number
  default = 0
}

variable "force_destroy_logs_bucket" {
  type    = bool
  default = false
}

variable "bot_forwarding_domains" {
  description = "Apex domains (keys of apex_domains) that should switch bots to S3."
  type        = set(string)
  default     = []
}

variable "bot_user_agent_pattern" {
  description = "Regex (without slashes) to detect bots in CF Function."
  type        = string
  default     = "testbot|udemybot" # safe test default
}

variable "bot_prefixes" {
  description = "Locale prefixes to serve via the secondary CF."
  type        = list(string)
  default     = ["website"]
}

variable "bot_bucket_name" {
  description = "Single S3 bucket for secondary CF content."
  type        = string
  default     = null
}