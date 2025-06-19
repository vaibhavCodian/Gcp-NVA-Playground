# ==============================================================================
# Final Corrected main.tf for 'dev' Environment
#
# This file is now the central point of logic. It defines the infrastructure
# layout (VPCs, subnets, etc.) in a `locals` block and then calls the modules
# with that data. This resolves the "Invalid index" and "empty plan" errors
# by no longer depending on variables that are not being set.
# ==============================================================================

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


# --- Module Instantiation ---

module "vpc" {
  source     = "../../modules/vpc"
  project_id = var.gcp_project_id
  vpcs       = local.vpcs
}

module "subnets" {
  source     = "../../modules/subnet"
  project_id = var.gcp_project_id
  region     = var.gcp_region
  subnets    = { for k, v in local.subnets : k => merge(v, {
    network_self_link = module.vpc.vpc_self_links[v.vpc_name]
  }) }
}

module "firewall_rules" {
  source         = "../../modules/firewall"
  project_id     = var.gcp_project_id
  network_name   = module.vpc.vpc_names["vpc-untrust"]
  firewall_rules = local.firewall_rules
  depends_on     = [module.vpc]
}

module "fortigate_instance" {
  source     = "../../modules/compute-instance"
  project_id = var.gcp_project_id
  zone       = var.gcp_zone
  instances  = { for k, v in local.compute_instances : k => merge(v, {
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
      # The startup-script now correctly reads from the locals block that processes the var.fortigate_config
      user-data = templatefile("../../templates/fortigate_config.tpl", {
        interfaces        = local.fortigate_interfaces
        static_routes     = local.fortigate_static_routes
        firewall_policies = local.fortigate_firewall_policies
        admin_users       = local.fortigate_admin_users
        dns               = local.fortigate_dns
        ntp_servers       = local.fortigate_ntp_servers
        address_objects   = local.fortigate_address_objects
        vips              = local.fortigate_vips
        vip_groups        = local.fortigate_vip_groups
        service_groups    = local.fortigate_service_groups
        zones             = local.fortigate_zones
        ha                = local.fortigate_ha
        log_settings      = local.fortigate_log_settings
        snmp              = local.fortigate_snmp
        radius_servers    = local.fortigate_radius_servers
        ldap_servers      = local.fortigate_ldap_servers
        ipsec_vpns        = local.fortigate_ipsec_vpns
        ssl_vpns          = local.fortigate_ssl_vpns
        custom_sections   = local.fortigate_custom_sections
      })
    }
  }) }
  depends_on = [module.firewall_rules]
}

module "test_vms" {
  source     = "../../modules/compute-instance"
  project_id = var.gcp_project_id
  zone       = var.gcp_zone
  instances  = {
    for k, v in local.compute_instances : k => merge(v,
      k == "web-server-untrust" ? {
        network_interfaces = [{
          subnet_self_link = module.subnets.subnet_self_links["fortinet-untrust-subnet"]
          nat              = true
        }]
      } :
      k == "db-server-trust" ? {
        network_interfaces = [{
          subnet_self_link = module.subnets.subnet_self_links["fortinet-trust-subnet"]
          nat              = false
        }]
      } :
      {}
    )
    if k != "fortigate-nva-instance-01"
  }
  depends_on = [module.subnets]
}

module "client_instances" {
  source     = "../../modules/compute-instance"
  project_id = var.gcp_project_id
  zone       = var.gcp_zone
  instances  = {
    for k, v in var.client_instances : k => merge(v,
      k == "client-untrust" ? {
        network_interfaces = [{
          subnet_self_link = module.subnets.subnet_self_links["fortinet-untrust-subnet"]
          nat              = true
        }]
      } :
      k == "client-trust" ? {
        network_interfaces = [{
          subnet_self_link = module.subnets.subnet_self_links["fortinet-trust-subnet"]
          nat              = false
        }]
      } : {}
    )
  }
  depends_on = [module.subnets]
}