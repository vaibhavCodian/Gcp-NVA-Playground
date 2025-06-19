# Global variables for the 'dev' environment.
variable "gcp_project_id" {
  description = "The GCP Project ID for the dev environment."
  type        = string
  default     = "vc-dev-lab-prj-1"
}

variable "gcp_region" {
  description = "The GCP region for deployment."
  type        = string
  default     = "asia-south1"
}

variable "gcp_zone" {
  description = "The GCP zone for deployment."
  type        = string
  default     = "asia-south1-b"
}

# Input variables for modules, to be defined in terraform.tfvars.
variable "vpcs" {
  description = "A map of VPC objects to create for this environment."
  type        = any
  default     = {}
}

variable "subnets" {
  description = "A map of subnet objects to create for this environment."
  type        = any
  default     = {}
}

variable "firewall_rules" {
  description = "A map of firewall rule objects to create for this environment."
  type        = any
  default     = {}
}

variable "compute_instances" {
  description = "A map of compute instance objects to create for this environment."
  type        = any
  default     = {}
}

variable "fortigate_internal_ip_with_mask" {
  description = "The static IP and subnet mask for the FortiGate's internal (trust) interface (e.g., 10.10.2.10 255.255.255.0)."
  type        = string
}

variable "fortigate_default_gateway" {
  description = "The default gateway for the FortiGate's external (untrust) subnet."
  type        = string
}

variable "fortigate_config" {
  description = "Map of objects for advanced FortiGate configuration."
  type        = any
}

variable "client_instances" {
  description = "A map of simple client/test VM instance objects to create for this environment. Used for firewall/FortiGate testing."
  type        = any
  default     = {}
}
