variable "project_id" {
  description = "The GCP project ID where the VPC will be created."
  type        = string
}
variable "vpcs" {
  description = "A map of VPC objects to create. The key is the VPC name."
  type = map(object({
    description             = optional(string, "VPC managed by Terraform")
    auto_create_subnetworks = optional(bool, false)
    routing_mode            = optional(string, "REGIONAL")
  }))
  default = {}
}
