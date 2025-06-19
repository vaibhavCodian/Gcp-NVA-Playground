variable "project_id" { type = string }
variable "routes" {
  type = map(object({
    network_name     = string
    dest_range       = string
    next_hop_ip      = string
    priority         = optional(number, 1000)
    tags             = optional(list(string), [])
  }))
  default = {}
}
