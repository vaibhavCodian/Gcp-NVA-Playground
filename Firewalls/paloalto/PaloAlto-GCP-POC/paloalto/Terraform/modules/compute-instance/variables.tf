variable "project_id" { type = string }
variable "zone" { type = string }
variable "instances" {
  type = map(object({
    machine_type = string
    boot_disk = object({
      image = string
      size  = optional(number, 81) # PAN-OS requires 81GB minimum
      type  = optional(string, "pd-ssd")
    })
    network_interfaces = list(object({
      subnet_self_link = string
      nat              = optional(bool, false)
      internal_ip      = optional(string)
    }))
    tags                  = optional(list(string), [])
    metadata              = optional(map(string), {})
    can_ip_forward        = optional(bool, false)
    service_account_email = optional(string)
  }))
  default = {}
}
