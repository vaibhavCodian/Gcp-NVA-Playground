terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

data "google_compute_default_service_account" "default" {}

# --- Define Infrastructure using Locals ---
locals {
  # Define the two distinct VPCs required for the multi-NIC architecture.
  vpcs = {
    "vpc-untrust" = { description = "External-facing VPC for PAN WAN" },
    "vpc-trust"   = { description = "Internal-facing VPC for PAN LAN" }
  }
  # Define the subnets and assign them to their respective VPCs.
  subnets = {
    "pan-untrust-subnet" = {
      vpc_name      = "vpc-untrust"
      ip_cidr_range = "10.20.1.0/24"
    },
    "pan-trust-subnet" = {
      vpc_name      = "vpc-trust"
      ip_cidr_range = "10.20.2.0/24"
    }
  }
  # Define the management firewall rule for the untrust VPC.
  firewall_rules = {
    "allow-pan-mgmt" = {
      description   = "Allow HTTPS/SSH for PAN management"
      source_ranges = ["0.0.0.0/0"] # WARNING: Restrict for production
      target_tags   = ["paloalto-vm"]
      allow = [
        { protocol = "tcp", ports = ["22", "443"] },
        { protocol = "icmp" }
      ]
    }
  }
}

# --- Instantiate Core Network Modules ---

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

# --- Palo Alto Bootstrapping Logic ---

module "bootstrap_bucket" {
  source     = "../../modules/gcs-bucket"
  project_id = var.gcp_project_id
  location   = var.gcp_region
  buckets    = {
    (var.bootstrap_bucket_name) = {}
  }
}

resource "google_storage_bucket_iam_member" "bootstrap_iam" {
  bucket = module.bootstrap_bucket.bucket_names[var.bootstrap_bucket_name]
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${data.google_compute_default_service_account.default.email}"
}

resource "google_storage_bucket_object" "init_cfg" {
  name    = "config/init-cfg.txt"
  bucket  = module.bootstrap_bucket.bucket_names[var.bootstrap_bucket_name]
  content = templatefile("../../bootstrap/config/init-cfg.txt", {
    admin_password = var.pan_admin_password
  })
}

resource "google_storage_bucket_object" "authcodes" {
  name   = "license/authcodes"
  bucket = module.bootstrap_bucket.bucket_names[var.bootstrap_bucket_name]
  source = "../../bootstrap/license/authcodes" # Uploads the empty file
}

# --- Instantiate Firewall and Test VMs ---

module "paloalto_instance" {
  source     = "../../modules/compute-instance"
  project_id = var.gcp_project_id
  zone       = var.gcp_zone
  instances  = {
    "paloalto-poc-vm" = {
      machine_type = "n2-standard-4" # PAN requires more resources
      boot_disk = {
        image = "projects/paloaltonetworksgcp-public/global/images/family/vmseries-flex"
      }
      tags                  = ["paloalto-vm"]
      can_ip_forward        = true
      service_account_email = data.google_compute_default_service_account.default.email
      network_interfaces = [
        { # nic0 for Management/Untrust
          subnet_self_link = module.subnets.subnet_self_links["pan-untrust-subnet"]
          nat              = true
        },
        { # nic1 for Trust, with a static IP
          subnet_self_link = module.subnets.subnet_self_links["pan-trust-subnet"]
          nat              = false
          internal_ip      = "10.20.2.4" # Static internal IP for routing
        }
      ]
      metadata = {
        # This metadata key triggers the bootstrap process
        vmseries-bootstrap-gcs-bucket = module.bootstrap_bucket.bucket_names[var.bootstrap_bucket_name]
      }
    }
  }
  depends_on = [
    module.firewall_rules,
    google_storage_bucket_object.init_cfg,
    google_storage_bucket_object.authcodes,
  ]
}

module "test_vm" {
  source     = "../../modules/compute-instance"
  project_id = var.gcp_project_id
  zone       = var.gcp_zone
  instances = {
    "poc-test-vm" = {
      machine_type = "e2-micro"
      boot_disk = {
        image = "projects/debian-cloud/global/images/family/debian-11"
        size  = 10
        type  = "pd-standard"
      }
      tags                  = ["test-vm"]
      service_account_email = data.google_compute_default_service_account.default.email
      network_interfaces = [{
        subnet_self_link = module.subnets.subnet_self_links["pan-trust-subnet"]
        nat              = false # No public IP for the test VM
      }]
    }
  }
}

# --- Create Route to Force Traffic Through Firewall ---
module "trust_default_route" {
  source     = "../../modules/route"
  project_id = var.gcp_project_id
  routes = {
    "trust-to-pan-fw" = {
      network_name = module.vpc.vpc_names["vpc-trust"]
      dest_range   = "0.0.0.0/0"
      # Point to the static internal IP of the Palo Alto's trust interface
      next_hop_ip  = "10.20.2.4"
      priority     = 900 # Higher priority than default internet gateway
      tags         = ["test-vm"]
    }
  }
  depends_on = [module.paloalto_instance]
}
