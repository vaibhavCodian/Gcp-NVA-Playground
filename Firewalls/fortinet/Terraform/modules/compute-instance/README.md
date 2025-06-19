# Compute Instance Module for Fortinet (GCP NVA)

This module creates Google Compute Engine instances for Fortinet (FortiGate) and can be adapted for other vendors. It is designed for modular, production-ready, and scalable deployments in GCP.

## Features
- Creates one or more Compute Engine instances with configurable machine type, boot disk, network interfaces, tags, and metadata.
- **Uses the default Compute Engine service account** for all VM deployments, following GCP best practices for least privilege and automation.
- Supports multiple network interfaces and NAT configuration.
- Lifecycle management to prevent unnecessary instance recreation on metadata changes.

## Example Usage
```hcl
module "fortigate_instance" {
  source     = "../../modules/compute-instance"
  project_id = var.gcp_project_id
  zone       = var.gcp_zone
  instances  = {
    "fortigate-1" = {
      machine_type = "n2-standard-2"
      boot_disk = {
        image = "fortinet-gcp-image"
        size  = 30
        type  = "pd-standard"
      }
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
      tags           = ["fortigate", "firewall"]
      metadata       = { startup-script = "..." }
      can_ip_forward = true
    }
  }
}
```

## Service Account
This module **always uses the default Compute Engine service account** with `cloud-platform` scope:
```hcl
service_account {
  email  = "default"
  scopes = ["https://www.googleapis.com/auth/cloud-platform"]
}
```
If you need to use a custom service account, modify the module accordingly.

## Inputs
- `project_id`: GCP project ID
- `zone`: GCP zone
- `instances`: Map of instance definitions (see above)

## Outputs
- Instance self-links, names, and other useful attributes (add as needed)

## Best Practices
- Restrict the default service account permissions using IAM.
- Use metadata and startup scripts for automation.
- Use Terraform state management best practices.

---
For more details, see the root and environment-level README files.
