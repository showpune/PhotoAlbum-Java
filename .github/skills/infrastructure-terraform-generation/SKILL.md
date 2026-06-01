---
name: infrastructure-terraform-generation
description: Generate Terraform IaC files for Azure infrastructure provisioning
---

# Infrastructure Terraform Generation

## Overview

Generate Terraform files to provision Azure infrastructure. Only use when user explicitly requests Terraform.

## Workflow

1. **Gather rules** (call these tools before generating):
   - Call `appmod-get-available-region-sku` to get available regions and SKUs
   - Call `appmod-get-iac-rules` with **deploymentTool=azcli** (Do NOT use azd)
   - For Azure landing zone, also call `appmod-get-waf-rules` to ensure Azure Well-Architected Framework compliance

2. **Generate files** in `./infra/` directory:

```
./infra/
├── main.tf                 # Main configuration
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── providers.tf            # Provider configuration (azurerm)
├── terraform.tfvars        # Variable values
├── modules/                # Reusable Terraform modules
│   └── [resource]/         # One module per resource type
├── deploy.sh               # Deployment script for Linux/macOS
├── deploy.ps1              # Deployment script for Windows
├── README.md               # Infrastructure documentation
└── compliance.md           # Rules compliance report
```

3. **Deployment scripts** must use Terraform CLI (`terraform init/plan/apply`).

## Success Criteria

- All Terraform files pass `terraform validate`
- Deployment scripts are executable
- README.md documents all resources and variables
