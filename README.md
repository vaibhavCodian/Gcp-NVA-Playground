# GCP NVA Reference Playground

A comprehensive, modular, and scalable open-source repository for deploying, automating, and managing Network Virtual Appliances (NVAs) on Google Cloud Platform (GCP) using Infrastructure as Code (Terraform).

## Overview
This repository provides:
- Production-grade Terraform modules and environment examples for a wide range of NVA vendors (firewalls, load balancers, SD-WAN, VPN, and more)
- Reference architectures, deployment patterns, and best practices for GCP network security
- Documentation for troubleshooting, cost optimization, and architecture diagrams
- A scalable folder structure to accommodate new NVA types and vendors

## Repository Structure

```
├── LICENSE
├── README.md                # This file
├── .gitignore
├── docs/                    # Architecture, troubleshooting, cost optimization, etc.
├── Firewalls/               # Vendor-specific NVA Terraform code (Fortinet, Palo Alto, etc.)
│   ├── fortinet/
│   ├── paloalto/
│   ├── ...
├── LoadBalancers/           # (e.g., F5, Citrix ADC)
├── WANOptimizers/           # (e.g., Riverbed, Silver Peak)
├── VPNGateways/             # (e.g., OpenVPN, Cisco AnyConnect)
├── WebProxies/              # (e.g., Zscaler, Blue Coat)
├── IDS-IPS/                 # (e.g., Snort, Suricata)
├── DDoSProtection/          # (e.g., Radware, Arbor)
├── SDWAN/                   # (e.g., VeloCloud, Versa)
├── NetworkPacketBrokers/    # (e.g., Gigamon, Ixia)
├── EmailSecurity/           # (e.g., Proofpoint, Barracuda)
├── DNSSecurity/             # (e.g., Infoblox, BlueCat)
├── APIGateways/             # (e.g., Apigee, Kong, NGINX)
```

## Key Features
- **Multi-vendor support:** Fortinet, Palo Alto, Check Point, Cisco, Sophos, Juniper, Barracuda, F5, and more
- **Modular Terraform code:** Reusable modules for VPC, subnets, firewall rules, compute, etc.
- **Environment overlays:** Example environments (dev, prod) for each vendor
- **Documentation:** Architecture diagrams, troubleshooting, and cost optimization guides in `docs/`
- **Security best practices:** Zero Trust, segmentation, HA, logging, and compliance
- **CI/CD ready:** Structure supports automation and policy-as-code pipelines

## Getting Started
1. Browse the `Firewalls/` or other NVA category folders for vendor-specific Terraform code and instructions
2. Review the `docs/` folder for architecture, troubleshooting, and cost optimization guidance
3. Clone and adapt modules/environments for your use case

## Contributing
Contributions are welcome! Please see the [LICENSE](LICENSE) for terms. Add new NVA vendors, modules, or documentation as needed.

## License
Apache 2.0

---

*This repository is intended as a reference for cloud network security architects, engineers, and the open-source community deploying NVAs on GCP.*