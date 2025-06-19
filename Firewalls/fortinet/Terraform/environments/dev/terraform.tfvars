# Environment-specific values for 'dev' with a corrected multi-VPC architecture.

# VPC Network Configuration
# We now define two separate VPCs: one for the external (untrust) interface
# and one for the internal (trust) interface.
vpcs = {
  "vpc-untrust" = {
    description             = "External-facing VPC for FortiGate WAN"
    auto_create_subnetworks = false
  },
  "vpc-trust" = {
    description             = "Internal-facing VPC for FortiGate LAN"
    auto_create_subnetworks = false
  }
}

# Subnet Configuration
# Each subnet is now explicitly assigned to its correct VPC.
subnets = {
  "fortinet-untrust-subnet" = {
    vpc_name      = "vpc-untrust" # Belongs to the untrust VPC
    ip_cidr_range = "10.10.1.0/24"
    description   = "External/Untrust subnet for FortiGate"
  },
  "fortinet-trust-subnet" = {
    vpc_name      = "vpc-trust" # Belongs to the trust VPC
    ip_cidr_range = "10.10.2.0/24"
    description   = "Internal/Trust subnet for FortiGate"
  }
}

# Firewall Rules
# The management firewall rule should only apply to the external-facing untrust VPC.
firewall_rules = {
  "allow-mgmt-access" = {
    description   = "Allow SSH and HTTPS for FortiGate management"
    source_ranges = ["0.0.0.0/0"] # WARNING: Open to the world. Restrict for production.
    target_tags   = ["fortigate-vm"]
    allow = [
      { protocol = "tcp", ports = ["22", "443"] },
      { protocol = "icmp" }
    ]
  }
}

# FortiGate VM Instance Configuration
compute_instances = {
  "fortigate-nva-instance-01" = {
    machine_type = "n1-standard-4"
    boot_disk = {
      image = "projects/fortigcp-project-001/global/images/family/fortigate-74-payg"
      size  = 30
      type  = "pd-balanced"
    }
    tags           = ["fortigate-vm"]
    can_ip_forward = true
    metadata = {}
  }
  "web-server-untrust" = {
    machine_type = "e2-micro"
    boot_disk = {
      image = "debian-cloud/debian-11"
      size  = 10
      type  = "pd-standard"
    }
    tags           = ["web-server", "untrust"]
    can_ip_forward = false
    metadata = {}
  }
  "db-server-trust" = {
    machine_type = "e2-micro"
    boot_disk = {
      image = "debian-cloud/debian-11"
      size  = 10
      type  = "pd-standard"
    }
    tags           = ["db-server", "trust"]
    can_ip_forward = false
    metadata = {}
  }
}

# Client/Tester VM Instance Configuration
client_instances = {
  "client-untrust" = {
    machine_type = "e2-micro"
    boot_disk = {
      image = "debian-cloud/debian-11"
      size  = 10
      type  = "pd-standard"
    }
    tags           = ["client-vm", "untrust"]
    can_ip_forward = false
    metadata = {}
  }
  "client-trust" = {
    machine_type = "e2-micro"
    boot_disk = {
      image = "debian-cloud/debian-11"
      size  = 10
      type  = "pd-standard"
    }
    tags           = ["client-vm", "trust"]
    can_ip_forward = false
    metadata = {}
  }
}

# FortiGate Startup Configuration Variables
fortigate_internal_ip_with_mask = "10.10.2.10 255.255.255.0"
fortigate_default_gateway       = "10.10.1.1"
