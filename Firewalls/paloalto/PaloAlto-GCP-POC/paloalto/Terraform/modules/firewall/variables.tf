variable "project_id" { type = string }
variable "network_name" { type = string }
variable "firewall_rules" {
  type = map(object({
    description   = optional(string)
    direction     = optional(string, "INGRESS")
    priority      = optional(number, 1000)
    source_ranges = optional(list(string))
    target_tags   = optional(list(string))
    allow = list(object({
      protocol = string
      ports    = optional(list(string))
    }))
  }))
  default = {}
}
