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
