---
name: infrastructure-bicep-generation
description: Generate Bicep IaC files for Azure infrastructure provisioning
---

# Infrastructure Bicep Generation

## Overview

Generate Bicep files to provision Azure infrastructure.

## Workflow

1. **Gather rules** (call these tools before generating):
   - Call `appmod-get-available-region-sku` to get available regions and SKUs
   - Call `appmod-get-iac-rules` with **deploymentTool=azcli** (Do NOT use azd)
   - For Azure landing zone, also call `appmod-get-waf-rules` to ensure Azure Well-Architected Framework compliance

2. **Generate files** in `./infra/` directory:

```
./infra/
├── main.bicep              # Main template, orchestrates all modules
├── parameters.json         # Environment-specific parameters
├── modules/                # Reusable Bicep modules
│   └── [resource].bicep    # One module per resource type
├── deploy.sh               # Deployment script for Linux/macOS
├── deploy.ps1              # Deployment script for Windows
├── README.md               # Infrastructure documentation
└── compliance.md           # Rules compliance report
```

3. **Deployment scripts** must use Azure CLI (`az deployment`), NOT azd.

## Success Criteria

- All Bicep files pass `az bicep build` validation
- Deployment scripts are executable
- README.md documents all resources and parameters
