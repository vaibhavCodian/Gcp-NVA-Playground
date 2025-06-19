variable "project_id" { type = string }
variable "region" { type = string }
variable "subnets" {
  type = map(object({
    network_self_link        = string
    ip_cidr_range            = string
    description              = optional(string, "Subnet managed by Terraform")
    private_ip_google_access = optional(bool, true)
  }))
  default = {}
}
