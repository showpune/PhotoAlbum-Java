# GitHub Prompts Directory

This directory contains prompt files and instructions for various automation and modernization tools.

## Contents

### `appmod-kit.create-plan.prompt.md`

This file provides comprehensive instructions for creating an Azure migration plan for the PhotoAlbum-Java application using the Application Modernization (AppMod) toolkit.

**Purpose:**
- Guide the migration process from local deployment to Azure
- Define Azure service recommendations
- Outline execution steps and tools to use
- Document migration considerations

**Key Sections:**
1. **Project Information** - Current technology stack and architecture
2. **Migration Plan Steps** - Step-by-step guide using AppMod tools
3. **Azure Service Recommendations** - Suggested Azure services for each component
4. **Migration Considerations** - Code changes and configuration updates needed
5. **Execution Order** - Sequence of operations for successful migration
6. **Success Criteria** - Validation checklist
7. **Expected Outputs** - Files and artifacts that will be generated

**How to Use:**
This prompt file serves as a reference guide for anyone (human or AI agent) working on the Azure migration. It provides:
- Tool names and parameters for AppMod toolkit
- Best practices for Azure deployment
- Security and configuration recommendations
- Troubleshooting guidance

**Related Files:**
- `.azure/plan.copilotmd` - The actual deployment plan generated from these instructions
- `.azure/progress.copilotmd` - Progress tracking during migration
- `.azure/APPMOD_INIT_SUMMARY.md` - Summary of what was accomplished

## Purpose of This Directory

The `.github/prompts/` directory is designed to store:
- Instructions for AI-assisted development and operations
- Migration and modernization guides
- Automation workflow prompts
- Best practices and conventions

By maintaining these prompts in version control:
- Team members can understand the migration approach
- AI tools have clear instructions for assistance
- The migration process is documented and repeatable
- Knowledge is preserved for future reference

## Contributing

When adding new prompt files:
1. Use descriptive filenames (e.g., `tool-name.action.prompt.md`)
2. Include clear sections with headers
3. Document tool parameters and expected outputs
4. Provide examples where helpful
5. Link to related documentation and files

## More Information

For details about the Azure migration plan, see:
- `.azure/plan.copilotmd` - Full deployment plan
- `.azure/APPMOD_INIT_SUMMARY.md` - Initialization summary
- `README.md` - Project overview and current setup
