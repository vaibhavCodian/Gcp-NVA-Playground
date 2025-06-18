variable "project_id" {
  description = "The GCP project ID for the subnets."
  type        = string
}

variable "region" {
  description = "The GCP region for the subnets."
  type        = string
}

variable "subnets" {
  description = "A map of subnet objects to create. The key is the subnet name."
  type = map(object({
    network_self_link        = string
    ip_cidr_range            = string
    description              = optional(string, "Subnet managed by Terraform")
    private_ip_google_access = optional(bool, true)
  }))
  default = {}
}
