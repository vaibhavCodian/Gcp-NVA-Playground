terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

module "vpc" {
  source     = "../../modules/vpc"
  project_id = var.gcp_project_id
  vpcs       = var.vpcs
}

module "subnets" {
  source     = "../../modules/subnet"
  project_id = var.gcp_project_id
  region     = var.gcp_region
  subnets    = { for k, v in var.subnets : k => merge(v, {
    network_self_link = module.vpc.vpc_self_links[v.vpc_name]
  }) }
}

# The firewall module now correctly and explicitly targets the 'vpc-untrust' network.
module "firewall_rules" {
  source         = "../../modules/firewall"
  project_id     = var.gcp_project_id
  network_name   = module.vpc.vpc_names["vpc-untrust"]
  firewall_rules = var.firewall_rules
  depends_on     = [module.vpc]
}

module "fortigate_instance" {
  source     = "../../modules/compute-instance"
  project_id = var.gcp_project_id
  zone       = var.gcp_zone
  instances  = { for k, v in var.compute_instances : k => merge(v, {
    network_interfaces = [
      {
        subnet_self_link = module.subnets.subnet_self_links["fortinet-untrust-subnet"]
        nat              = true
      },
      {
        subnet_self_link = module.subnets.subnet_self_links["fortinet-trust-subnet"]
        nat              = false
      }
    ]
    metadata = {
      startup-script = templatefile("../../templates/fortigate_config.tpl", {
        internal_ip_with_mask = var.fortigate_internal_ip_with_mask
        default_gateway_ip    = var.fortigate_default_gateway
      })
    }
  }) }
  depends_on = [module.firewall_rules]
}
