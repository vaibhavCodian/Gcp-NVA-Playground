variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "zone" {
  description = "The GCP zone for the instances."
  type        = string
}

variable "instances" {
  description = "A map of compute instance objects to create. The key is the instance name."
  type = map(object({
    machine_type = string
    boot_disk = object({
      image = string
      size  = optional(number, 30)
      type  = optional(string, "pd-standard")
    })
    network_interfaces = list(object({
      subnet_self_link = string
      nat              = optional(bool, false)
    }))
    tags           = optional(list(string), [])
    metadata       = optional(map(string), {})
    can_ip_forward = optional(bool, false)
  }))
  default = {}
}
