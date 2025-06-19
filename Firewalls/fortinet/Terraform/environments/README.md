# Environments Directory

This directory contains environment-specific Terraform configurations for deploying Fortinet (FortiGate) and other NVA solutions in GCP.

## Structure
- Each subfolder (e.g., `dev`, `prod`) contains a complete set of Terraform files for that environment.
- The `main.tf` in each environment references shared modules and templates.

## Service Account Usage
**All Fortinet VM deployments use the default Compute Engine service account** for simplicity and security best practices. No custom service account is set in the environment configuration. If you require a custom service account, update the compute-instance module and environment configuration accordingly.

## How to Use
1. Edit the variables in `terraform.tfvars` for your environment.
2. Run `terraform init`, `terraform plan`, and `terraform apply` as usual.
3. The Fortinet VM(s) will be created using the default Compute Engine service account.

## Best Practices
- Restrict permissions of the default service account using IAM.
- Use separate state files for each environment.
- Review and update firewall rules and network settings per environment needs.

---
For more details, see the module-level and root README files.
