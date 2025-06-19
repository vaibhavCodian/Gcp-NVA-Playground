#!/bin/bash

# ==============================================================================
# Polymathic AI System Architect: Palo Alto GCP POC Codebase Generator
#
# CONTEXT ANALYSIS:
# The user has provided a comprehensive Fortinet Terraform repository structure.
# This script synthesizes that structure and applies it to a Palo Alto VM-Series
# deployment, incorporating vendor-specific best practices.
#
# CORE REQUIREMENTS & BEST PRACTICES IMPLEMENTED:
# 1.  **Modular Design:** Replicates the modules/environments structure.
# 2.  **Environment Separation:** Creates a 'dev' environment, isolated from others.
# 3.  **Palo Alto Bootstrapping:** Implements the standard GCP bootstrap method
#     using a GCS bucket, which is the correct pattern for PAN-OS, differing
#     from FortiGate's simpler user-data script.
# 4.  **Test Harness:** Includes a test VM and the necessary routing to validate
#     the firewall's functionality post-deployment.
# 5.  **Comprehensive Documentation:** Generates high-quality READMEs and a
#     detailed SetupGuide.md explaining the unique steps for Palo Alto.
# 6.  **Minimum Viable POC:** The bootstrap configuration is intentionally simple,
#     focusing on getting the firewall online and ready for manual policy config.
# ==============================================================================

# --- Configuration: Root Project Directory ---
ROOT_DIR="PaloAlto-GCP-POC"
echo "Initializing Palo Alto POC project structure in root directory: $ROOT_DIR"

# --- Phase 1: Architecting the Directory Hierarchy ---
echo "Creating hierarchical folder structure..."
mkdir -p "$ROOT_DIR/paloalto/Terraform/environments/dev"
mkdir -p "$ROOT_DIR/paloalto/Terraform/modules/compute-instance"
mkdir -p "$ROOT_DIR/paloalto/Terraform/modules/firewall"
mkdir -p "$ROOT_DIR/paloalto/Terraform/modules/gcs-bucket"
mkdir -p "$ROOT_DIR/paloalto/Terraform/modules/route"
mkdir -p "$ROOT_DIR/paloalto/Terraform/modules/subnet"
mkdir -p "$ROOT_DIR/paloalto/Terraform/modules/vpc"
mkdir -p "$ROOT_DIR/paloalto/Terraform/bootstrap/config"
mkdir -p "$ROOT_DIR/paloalto/Terraform/bootstrap/license"
echo "Directory structure created successfully."

# --- Phase 2: Generating High-Level Documentation ---

# Palo Alto Root README
cat <<'EOF' > "$ROOT_DIR/paloalto/README.md"
# Palo Alto Networks VM-Series Terraform Reference for GCP

This folder contains a complete, modular, and best-practice Terraform codebase for deploying Palo Alto Networks VM-Series Next-Generation Firewalls (NGFW) on Google Cloud Platform.

This reference architecture is designed for a Proof of Concept (POC) but is built on principles that can be extended for production use.

---

## What is a Palo Alto Networks VM-Series NVA?
The **VM-Series** is the virtualized version of Palo Alto Networks' industry-leading hardware firewalls. It provides the same comprehensive security features, including:
- **App-ID:** Identifies and controls applications, irrespective of port, protocol, or encryption.
- **Threat Prevention:** Protects against known and unknown threats, including malware, exploits, and command-and-control traffic.
- **URL Filtering:** Controls access to websites based on category and risk.
- **WildFire:** Provides automated sandboxing and analysis for unknown threats.
- **User-ID:** Integrates with directory services to enable user-based policies.
- **VPN (IPsec/SSL):** Securely connects remote sites and users.
- **Advanced Routing & Segmentation:** Provides robust network control.

---

## Key Concept: Bootstrapping on GCP

Unlike some other NVAs that use a simple startup script, the VM-Series on GCP uses a more robust **bootstrapping** process. This involves a Google Cloud Storage (GCS) bucket that the firewall reads from on its first boot.

**Bootstrap Process:**
1.  A GCS bucket is created with a specific folder structure (`/config`, `/license`, `/software`, `/content`).
2.  Terraform generates an initial configuration file (`init-cfg.txt`) and uploads it to the `/config` folder in the bucket.
3.  Terraform creates the VM-Series instance and passes the name of the GCS bucket in its metadata.
4.  On first boot, the VM-Series instance authenticates to the GCS bucket, downloads the configuration, and applies it.

```mermaid
graph TD
    A[Terraform] -->|Creates| B(GCS Bucket)
    A -->|Uploads| C(init-cfg.txt)
    C --> B
    A -->|Creates VM with Metadata| D[Palo Alto VM]
    D -- Reads Metadata --> B
    D -- Downloads & Applies --> C
    E[Configured Palo Alto Firewall]
    C --> E

Architecture Deployed by This Codebase

This POC deploys a single VM-Series firewall in a multi-NIC architecture, which is the standard for inspecting traffic.

Generated mermaid
flowchart TD
    subgraph "Untrust VPC"
        A[Internet] --> B[GCP Firewall Rule]
        B --> C{nic0}
    end
    subgraph "Trust VPC"
        F[Test VM] --> E{nic1}
        G[Default Route 0.0.0.0/0] --> E
    end

    subgraph "Palo Alto VM-Series"
        C -- External --
        E -- Internal --
    end

    C -- Manages --> E

    style F fill:#eff,stroke:#333,stroke-width:2px
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Mermaid
IGNORE_WHEN_COPYING_END

Diagram Explanation:

Two VPCs: A hard requirement for multi-NIC appliances on GCP. vpc-untrust faces the internet, and vpc-trust contains internal applications.

Palo Alto VM: Has two network interfaces (NICs), one in each VPC.

GCP Firewall Rule: Allows management access (HTTPS/SSH) to the firewall's external interface (nic0).

Test VM: A simple Debian VM deployed into the vpc-trust to validate connectivity.

Default Route: A route is created in the vpc-trust network that forces all outbound traffic from the Test VM to be sent to the Palo Alto's internal interface (nic1) for inspection.

For detailed deployment and verification steps, see the SetupGuide.md file.
EOF

Palo Alto Setup Guide

cat <<'EOF' > "$ROOT_DIR/paloalto/SetupGuide.md"

Palo Alto VM-Series on GCP: Setup and Verification Guide

This guide provides a complete, step-by-step process for deploying and testing the Palo Alto VM-Series firewall using the provided Terraform codebase.

Step 1: Prerequisites

Google Cloud SDK: Ensure you have gcloud installed and configured.

Generated bash
gcloud auth login
gcloud auth application-default login
gcloud config set project [YOUR_GCP_PROJECT_ID]
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Bash
IGNORE_WHEN_COPYING_END

Terraform: Ensure you have Terraform v1.0 or newer installed.

Enable APIs: Make sure the Compute Engine API is enabled in your project.

Generated bash
gcloud services enable compute.googleapis.com
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Bash
IGNORE_WHEN_COPYING_END
Step 2: Configuration

Navigate to the dev environment directory:

Generated bash
cd paloalto/Terraform/environments/dev```

Open the `terraform.tfvars` file. You must configure two variables:

1.  **`pan_admin_password`**: Set a strong password for the `admin` user on the firewall.
    ```tfvars
    # Example:
    pan_admin_password = "MySecureP@ssw0rd123!"
    ```

2.  **`bootstrap_bucket_name`**: This **must be a globally unique name**. A good practice is to append a random number or your project ID.
    ```tfvars
    # Example:
    bootstrap_bucket_name = "pan-bootstrap-poc-vc-dev-lab-9876"
    ```

---

## Step 3: Deployment

1.  **Initialize Terraform:**
    ```bash
    terraform init
    ```
2.  **Review the Plan:**
    ```bash
    terraform plan
    ```
3.  **Apply the Configuration:** This will create all the resources. The Palo Alto VM may take 5-10 minutes to boot and bootstrap fully.
    ```bash
    terraform apply -auto-approve
    ```

---

## Step 4: Post-Deployment Verification & Configuration

This is the most critical part. Unlike the FortiGate, the Palo Alto firewall's default policy is to **deny all traffic**. You must manually create policies to allow traffic to flow.

### 4.1. Log in to the Palo Alto GUI (PAN-OS)

1.  **Get the Public IP:** From the `terraform apply` output, find the `paloalto_vm_details`.
2.  **Navigate:** Open a browser and go to `https://<YOUR_PALO_ALTO_PUBLIC_IP>`. Accept the self-signed certificate warning.
3.  **Credentials:**
    *   **Username:** `admin`
    *   **Password:** The `pan_admin_password` you set in your `.tfvars` file.

### 4.2. Verify Interfaces

1.  Go to the **Network** tab.
2.  In the left pane, click **Interfaces > Ethernet**.
3.  You should see that `ethernet1/1` and `ethernet1/2` have received IP addresses via DHCP from GCP. `ethernet1/1` will be your external (untrust) interface, and `ethernet1/2` will be your internal (trust) interface.

### 4.3. Create Security & NAT Policies (CRITICAL STEP)

You must create two rules to allow your test VM to reach the internet.

#### **A. Create the Outbound NAT Policy**
This rule translates the private IP of your test VM to the public IP of the firewall.

1.  Go to the **Policies** tab.
2.  In the left pane, select **NAT**.
3.  Click **Add** at the bottom.
4.  In the **General** tab, give it a name like `Outbound-NAT`.
5.  In the **Original Packet** tab:
    *   **Source Zone:** Click **Add** and select `trust`.
    *   **Destination Zone:** Click **Add** and select `untrust`.
    *   **Destination Interface:** Select `ethernet1/1`.
6.  In the **Translated Packet** tab:
    *   **Translation Type:** Select `Dynamic IP And Port`.
    *   **Address Type:** Select `Interface Address`.
    *   **Interface:** Select `ethernet1/1`.
7.  Click **OK**.

#### **B. Create the Security Policy**
This rule allows traffic from the trust zone to the untrust zone.

1.  In the left pane, select **Security**.
2.  Click **Add** at the bottom.
3.  In the **General** tab, give it a name like `Allow-Trust-to-Untrust`.
4.  In the **Source** tab:
    *   **Source Zone:** Click **Add** and select `trust`.
5.  In the **Destination** tab:
    *   **Destination Zone:** Click **Add** and select `untrust`.
6.  In the **Actions** tab:
    *   **Action:** Ensure it is set to `Allow`.
7.  Click **OK**.

### 4.4. Commit Your Changes

This is the most important step in PAN-OS. Your changes are not active until you commit them.

1.  Click the **Commit** button in the top-right corner of the GUI.
2.  In the new window, click **Commit** again.
3.  Wait for the commit process to complete (1-2 minutes).

---

## Step 5: Test Your Setup

1.  **SSH into the Test VM:** Use the GCP console or `gcloud` to SSH into the `poc-test-vm`.
    ```bash
    gcloud compute ssh poc-test-vm --zone [your_zone]
    ```
2.  **Test Internet Connectivity:** From inside the test VM, run a `curl` command.
    ```bash
    curl -v https://www.google.com
    ```
    If you see a successful HTML response, your traffic is flowing correctly from the trust zone, through the Palo Alto firewall, and out to the internet!

3.  **View Logs:** Go back to the Palo Alto GUI, navigate to the **Monitor** tab, and you will see log entries for the traffic from your test VM, confirming that the firewall is inspecting the traffic.
EOF

# --- Phase 3: Generating Terraform Modules ---

# Module: vpc
echo "Generating module: vpc"
cat <<'EOF' > "$ROOT_DIR/paloalto/Terraform/modules/vpc/variables.tf"
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
EOF
cat <<'EOF' > "$ROOT_DIR/paloalto/Terraform/modules/vpc/main.tf"
resource "google_compute_network" "vpc" {
  for_each = var.vpcs
  project                 = var.project_id
  name                    = each.key
  description             = each.value.description
  auto_create_subnetworks = each.value.auto_create_subnetworks
  routing_mode            = each.value.routing_mode
  lifecycle {
    create_before_destroy = true
  }
}
EOF
cat <<'EOF' > "$ROOT_DIR/paloalto/Terraform/modules/vpc/outputs.tf"
output "vpc_self_links" {
  description = "The self-links of the created VPCs."
  value       = { for k, v in google_compute_network.vpc : k => v.self_link }
}
output "vpc_names" {
  description = "The names of the created VPCs."
  value       = { for k, v in google_compute_network.vpc : k => v.name }
}
output "vpc_ids" {
  description = "The IDs of the created VPCs."
  value       = { for k, v in google_compute_network.vpc : k => v.id }
}
EOF

# Module: subnet
echo "Generating module: subnet"
cat <<'EOF' > "$ROOT_DIR/paloalto/Terraform/modules/subnet/variables.tf"
variable "project_id" { type = string }
variable "region" { type = string }
variable "subnets" {
  type = map(object({
    network_self_link        = string
    ip_cidr_range            = string
    description              = optional(string, "Subnet managed by Terraform")
    private_ip_google_access = optional(bool, true)
  }))
  default = {}
}
EOF
cat <<'EOF' > "$ROOT_DIR/paloalto/Terraform/modules/subnet/main.tf"
resource "google_compute_subnetwork" "subnet" {
  for_each = var.subnets
  project                  = var.project_id
  name                     = each.key
  region                   = var.region
  network                  = each.value.network_self_link
  ip_cidr_range            = each.value.ip_cidr_range
  description              = each.value.description
  private_ip_google_access = each.value.private_ip_google_access
  lifecycle {
    create_before_destroy = true
  }
}
EOF
cat <<'EOF' > "$ROOT_DIR/paloalto/Terraform/modules/subnet/outputs.tf"
output "subnet_self_links" {
  value = { for k, v in google_compute_subnetwork.subnet : k => v.self_link }
}
output "subnet_internal_ips" {
  value = { for k, v in google_compute_subnetwork.subnet : k => v.gateway_address }
}
EOF

# Module: firewall
echo "Generating module: firewall"
cat <<'EOF' > "$ROOT_DIR/paloalto/Terraform/modules/firewall/variables.tf"
variable "project_id" { type = string }
variable "network_name" { type = string }
variable "firewall_rules" {
  type = map(object({
    description   = optional(string)
    direction     = optional(string, "INGRESS")
    priority      = optional(number, 1000)
    source_ranges = optional(list(string))
    target_tags   = optional(list(string))
    allow = list(object({
      protocol = string
      ports    = optional(list(string))
    }))
  }))
  default = {}
}
EOF
cat <<'EOF' > "$ROOT_DIR/paloalto/Terraform/modules/firewall/main.tf"
resource "google_compute_firewall" "firewall" {
  for_each      = var.firewall_rules
  project       = var.project_id
  name          = each.key
  network       = var.network_name
  description   = each.value.description
  direction     = each.value.direction
  priority      = each.value.priority
  source_ranges = each.value.source_ranges
  target_tags   = each.value.target_tags
  dynamic "allow" {
    for_each = each.value.allow
    content {
      protocol = allow.value.protocol
      ports    = lookup(allow.value, "ports", null)
    }
  }
}
EOF
cat <<'EOF' > "$ROOT_DIR/paloalto/Terraform/modules/firewall/outputs.tf"
output "firewall_names" {
  value = [for k, v in google_compute_firewall.firewall : v.name]
}
EOF

# Module: compute-instance
echo "Generating module: compute-instance"
cat <<'EOF' > "$ROOT_DIR/paloalto/Terraform/modules/compute-instance/variables.tf"
variable "project_id" { type = string }
variable "zone" { type = string }
variable "instances" {
  type = map(object({
    machine_type = string
    boot_disk = object({
      image = string
      size  = optional(number, 81) # PAN-OS requires 81GB minimum
      type  = optional(string, "pd-ssd")
    })
    network_interfaces = list(object({
      subnet_self_link = string
      nat              = optional(bool, false)
      internal_ip      = optional(string)
    }))
    tags                  = optional(list(string), [])
    metadata              = optional(map(string), {})
    can_ip_forward        = optional(bool, false)
    service_account_email = optional(string)
  }))
  default = {}
}
EOF
cat <<'EOF' > "$ROOT_DIR/paloalto/Terraform/modules/compute-instance/main.tf"
resource "google_compute_instance" "instance" {
  for_each = var.instances
  project        = var.project_id
  zone           = var.zone
  name           = each.key
  machine_type   = each.value.machine_type
  tags           = each.value.tags
  can_ip_forward = each.value.can_ip_forward

  boot_disk {
    initialize_params {
      image = each.value.boot_disk.image
      size  = each.value.boot_disk.size
      type  = each.value.boot_disk.type
    }
  }

  dynamic "network_interface" {
    for_each = each.value.network_interfaces
    content {
      subnetwork = network_interface.value.subnet_self_link
      network_ip = lookup(network_interface.value, "internal_ip", null)
      dynamic "access_config" {
        for_each = network_interface.value.nat ? [1] : []
        content {}
      }
    }
  }

  metadata = each.value.metadata

  service_account {
    email  = each.value.service_account_email
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [metadata]
  }
}
EOF
cat <<'EOF' > "$ROOT_DIR/paloalto/Terraform/modules/compute-instance/outputs.tf"
output "instance_details" {
  description = "Details of the created compute instances."
  value = { for k, v in google_compute_instance.instance : k => {
    name           = v.name
    instance_id    = v.instance_id
    external_ips   = [for nic in v.network_interface : try(nic.access_config[0].nat_ip, null)]
    internal_ips   = [for nic in v.network_interface : v.network_ip]
  }}
}
EOF

# Module: gcs-bucket
echo "Generating module: gcs-bucket"
cat <<'EOF' > "$ROOT_DIR/paloalto/Terraform/modules/gcs-bucket/variables.tf"
variable "project_id" { type = string }
variable "location" { type = string }
variable "buckets" {
  type = map(object({
    force_destroy = optional(bool, true)
    storage_class = optional(string, "STANDARD")
  }))
  default = {}
}
EOF
cat <<'EOF' > "$ROOT_DIR/paloalto/Terraform/modules/gcs-bucket/main.tf"
resource "google_storage_bucket" "bucket" {
  for_each      = var.buckets
  project       = var.project_id
  name          = each.key
  location      = var.location
  force_destroy = each.value.force_destroy
  storage_class = each.value.storage_class
}
EOF
cat <<'EOF' > "$ROOT_DIR/paloalto/Terraform/modules/gcs-bucket/outputs.tf"
output "bucket_names" {
  value = { for k, v in google_storage_bucket.bucket : k => v.name }
}
EOF

# Module: route
echo "Generating module: route"
cat <<'EOF' > "$ROOT_DIR/paloalto/Terraform/modules/route/variables.tf"
variable "project_id" { type = string }
variable "routes" {
  type = map(object({
    network_name     = string
    dest_range       = string
    next_hop_ip      = string
    priority         = optional(number, 1000)
    tags             = optional(list(string), [])
  }))
  default = {}
}
EOF
cat <<'EOF' > "$ROOT_DIR/paloalto/Terraform/modules/route/main.tf"
resource "google_compute_route" "route" {
  for_each = var.routes
  project      = var.project_id
  name         = each.key
  network      = each.value.network_name
  dest_range   = each.value.dest_range
  next_hop_ip  = each.value.next_hop_ip
  priority     = each.value.priority
  tags         = each.value.tags
}
EOF
cat <<'EOF' > "$ROOT_DIR/paloalto/Terraform/modules/route/outputs.tf"
output "route_names" {
  value = [for k, v in google_compute_route.route : v.name]
}
EOF


# --- Phase 4: Generating Palo Alto Bootstrap Files ---
echo "Generating Palo Alto bootstrap files..."
cat <<'EOF' > "$ROOT_DIR/paloalto/Terraform/bootstrap/config/init-cfg.txt"
# This is a minimal bootstrap configuration for a Palo Alto VM-Series POC.
# It sets the hostname, admin password, and enables DHCP on dataplane interfaces.
type=dhcp-client
hostname=paloalto-fw-poc
mgmt-interface-swap=enable
admin-username=admin
admin-password=${admin_password}
dhcp-send-hostname=yes
dhcp-send-client-id=yes
EOF

# Create the mandatory but empty authcodes file
touch "$ROOT_DIR/paloalto/Terraform/bootstrap/license/authcodes"


# --- Phase 5: Composing the 'dev' Environment ---
echo "Generating 'dev' environment configuration for Palo Alto..."

# Environment: variables.tf
cat <<'EOF' > "$ROOT_DIR/paloalto/Terraform/environments/dev/variables.tf"
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
EOF

# Environment: terraform.tfvars
cat <<'EOF' > "$ROOT_DIR/paloalto/Terraform/environments/dev/terraform.tfvars"
# NOTE: Set a strong password in a production environment.
pan_admin_password = "PaloAlto-GCP-2025!"

# NOTE: GCS bucket names must be globally unique across all of Google Cloud.
# Change this if you get a bucket creation error during 'terraform apply'.
bootstrap_bucket_name = "pan-bootstrap-poc-bucket-unique-12345"
EOF

# Environment: main.tf
cat <<'EOF' > "$ROOT_DIR/paloalto/Terraform/environments/dev/main.tf"
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
EOF

# Environment: outputs.tf
cat <<'EOF' > "$ROOT_DIR/paloalto/Terraform/environments/dev/outputs.tf"
output "paloalto_vm_details" {
  description = "Details of the deployed Palo Alto VM. Use the password from your .tfvars file."
  value       = module.paloalto_instance.instance_details
}
output "next_steps" {
  description = "Instructions for accessing the Palo Alto appliance."
  value       = "Navigate to https://<EXTERNAL_IP>/. Use username 'admin' and the password you set in terraform.tfvars."
}
output "test_vm_name" {
  description = "Name of the internal test VM to SSH into."
  value       = module.test_vm.instance_details["poc-test-vm"].name
}
EOF


# --- Finalization ---
echo ""
echo "------------------------------------------------------------------"
echo "Palo Alto POC codebase generated successfully in '$ROOT_DIR/'"
echo "------------------------------------------------------------------"
echo ""
echo "CRITICAL: Before you deploy, please read the Setup Guide:"
echo "          '$ROOT_DIR/paloalto/SetupGuide.md'"
echo ""
echo "You MUST edit the following file before running 'terraform apply':"
echo "  - '$ROOT_DIR/paloalto/Terraform/environments/dev/terraform.tfvars'"
echo ""
echo "Set a unique bucket name and a secure admin password."
echo ""
echo "Once configured, run the following commands:"
echo "1. cd \"$ROOT_DIR/paloalto/Terraform/environments/dev\""
echo "2. terraform init"
echo "3. terraform apply -auto-approve"
echo "------------------------------------------------------------------"
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Bash
IGNORE_WHEN_COPYING_END