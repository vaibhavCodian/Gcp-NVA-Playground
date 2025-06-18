variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "network_name" {
  description = "The name of the VPC network for the firewall rules."
  type        = string
}

variable "firewall_rules" {
  description = "A map of firewall rule objects to create. The key is the rule name."
  type = map(object({
    description   = optional(string, "Firewall rule managed by Terraform")
    direction     = optional(string, "INGRESS")
    priority      = optional(number, 1000)
    source_ranges = optional(list(string), ["0.0.0.0/0"])
    target_tags   = optional(list(string), [])
    allow = list(object({
      protocol = string
      ports    = optional(list(string), [])
    }))
  }))
  default = {}
}
