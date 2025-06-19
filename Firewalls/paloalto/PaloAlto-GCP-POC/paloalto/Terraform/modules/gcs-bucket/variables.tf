variable "project_id" { type = string }
variable "location" { type = string }
variable "buckets" {
  type = map(object({
    force_destroy = optional(bool, true)
    storage_class = optional(string, "STANDARD")
  }))
  default = {}
}
