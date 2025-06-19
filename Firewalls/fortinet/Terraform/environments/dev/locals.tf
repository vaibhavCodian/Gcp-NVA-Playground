# Locals for rendering complex Fortinet configuration from map.
# This version uses a safe pass-through pattern to preserve all optional attributes.
locals {
  # Use try() to provide an empty list/object if the top-level key doesn't exist in the tfvars.
  fortigate_interfaces        = try(var.fortigate_config.interfaces, [])
  fortigate_static_routes     = try(var.fortigate_config.static_routes, [])
  fortigate_firewall_policies = try(var.fortigate_config.firewall_policies, [])
  fortigate_admin_users       = try(var.fortigate_config.admin_users, [])
  fortigate_dns               = try(var.fortigate_config.dns, null)
  fortigate_ntp_servers       = try(var.fortigate_config.ntp_servers, [])
  fortigate_address_objects   = try(var.fortigate_config.address_objects, [])
  fortigate_vips              = try(var.fortigate_config.vips, [])
  fortigate_vip_groups        = try(var.fortigate_config.vip_groups, [])
  fortigate_service_groups    = try(var.fortigate_config.service_groups, [])
  fortigate_zones             = try(var.fortigate_config.zones, [])
  fortigate_ha                = try(var.fortigate_config.ha, null)
  fortigate_log_settings      = try(var.fortigate_config.log_settings, null)
  fortigate_snmp              = try(var.fortigate_config.snmp, null)
  fortigate_radius_servers    = try(var.fortigate_config.radius_servers, [])
  fortigate_ldap_servers      = try(var.fortigate_config.ldap_servers, [])
  fortigate_ipsec_vpns        = try(var.fortigate_config.ipsec_vpns, [])
  fortigate_ssl_vpns          = try(var.fortigate_config.ssl_vpns, [])
  fortigate_custom_sections   = try(var.fortigate_config.custom_sections, [])
}


# --- Local Infrastructure Definitions ---
# This locals block defines the static parts of our infrastructure.
# This makes the module calls below clean and readable.
locals {
  # Define the two distinct VPCs required for the multi-NIC architecture.
  vpcs = {
    "vpc-untrust" = {
      description = "External-facing VPC for FortiGate WAN"
    },
    "vpc-trust" = {
      description = "Internal-facing VPC for FortiGate LAN"
    }
  }

  # Define the subnets and assign them to their respective VPCs.
  subnets = {
    "fortinet-untrust-subnet" = {
      vpc_name      = "vpc-untrust"
      ip_cidr_range = "10.10.1.0/24"
      description   = "External/Untrust subnet for FortiGate"
    },
    "fortinet-trust-subnet" = {
      vpc_name      = "vpc-trust"
      ip_cidr_range = "10.10.2.0/24"
      description   = "Internal/Trust subnet for FortiGate"
    }
  }

  # Define the management firewall rule for the untrust VPC.
  firewall_rules = {
    "allow-mgmt-access" = {
      description   = "Allow SSH and HTTPS for FortiGate management"
      source_ranges = ["0.0.0.0/0"]
      target_tags   = ["fortigate-vm"]
      allow = [
        { protocol = "tcp", ports = ["22", "443"] },
        { protocol = "icmp" }
      ]
    }
  }

  # Define the FortiGate VM instance.
  compute_instances = var.compute_instances
}