variable "waf_rules_override_action" {
  description = "Two options: 'none' - rules are active, 'count' - they are only counted and requests are always passed on"
  default     = "none"
}
