variable "gcp_project_id" {
  description = "The GCP Project ID."
  type        = string
  default     = "vc-dev-lab-prj-1" # Change if necessary
}
variable "gcp_region" {
  description = "The GCP region for deployment."
  type        = string
  default     = "asia-south1"
}
variable "gcp_zone" {
  description = "The GCP zone for deployment."
  type        = string
  default     = "asia-south1-a"
}
variable "pan_admin_password" {
  description = "The admin password for the Palo Alto VM-Series."
  type        = string
  sensitive   = true
}
variable "bootstrap_bucket_name" {
  description = "A globally unique name for the GCS bootstrap bucket."
  type        = string
}
