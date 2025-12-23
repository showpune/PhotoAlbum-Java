# Create Modernization Plan Skill

## Description
This skill analyzes the PhotoAlbum-Java project and creates a comprehensive modernization plan for migrating the application to Microsoft Azure.

## Prerequisites
- Java project with Maven build system
- Existing application structure and dependencies
- Target Azure deployment environment

## Skill Execution Steps

### 1. Analyze Repository Structure
First, analyze the repository to understand:
- Programming languages and frameworks used
- Build systems and dependencies
- Application architecture and components
- Database requirements
- Current technology stack

### 2. Detect Services and Dependencies
Identify the services that need to be deployed:
- Main application service (Spring Boot Java application)
- Dependencies:
  - Oracle Database (needs migration strategy)
  - Static resources and templates
  - File storage (currently using database BLOBs)

### 3. Recommend Azure Services
Based on the analysis, recommend appropriate Azure services:
- **Compute**: Azure Container Apps, Azure App Service, or Azure Kubernetes Service
- **Database**: Azure Database for PostgreSQL or Azure SQL Database (migration from Oracle)
- **Storage**: Azure Blob Storage for photo storage (migrate from database BLOBs)
- **Additional Services**: 
  - Azure Container Registry for container images
  - Azure Key Vault for secrets management
  - Application Insights for monitoring

### 4. Create Deployment Plan
Generate a deployment plan using the `appmod-get-plan` tool that includes:
- Infrastructure as Code (Bicep or Terraform) requirements
- Containerization strategy (Dockerfile already exists)
- CI/CD pipeline recommendations
- Migration steps from Oracle to Azure database
- Configuration changes needed

### 5. Generate Migration Artifacts
Create necessary artifacts:
- Azure infrastructure templates
- Docker configuration (if needed)
- CI/CD pipeline definitions
- Migration scripts and documentation

## Expected Outputs
1. **Modernization Plan Document**: `.azure/plan.copilotmd` containing:
   - Current state assessment
   - Recommended Azure architecture
   - Step-by-step migration plan
   - Infrastructure requirements
   - Cost estimates and considerations

2. **Infrastructure Templates**: Bicep or Terraform files for Azure resources

3. **Migration Guide**: Documentation for database and storage migration

## Tool Usage
This skill leverages the following tools:
- `app-modernization-appmod-analyze-repository`: Analyze the repository structure
- `app-modernization-appmod-get-plan`: Generate deployment and migration plan
- `app-modernization-appmod-get-iac-rules`: Get infrastructure as code best practices

## Project-Specific Considerations

### Current Stack (PhotoAlbum-Java)
- **Framework**: Spring Boot 2.7.18
- **Java Version**: 1.8
- **Database**: Oracle Database 21c Express Edition
- **Storage**: Photos stored as BLOBs in database
- **Build Tool**: Maven
- **Containerization**: Docker and Docker Compose configured

### Migration Priorities
1. **Database Migration**: Oracle DB → Azure PostgreSQL or Azure SQL
2. **Storage Migration**: Database BLOBs → Azure Blob Storage
3. **Compute Migration**: Docker containers → Azure Container Apps or App Service
4. **Dependency Updates**: Consider upgrading Spring Boot and Java versions
5. **Configuration**: Externalize configuration to Azure App Configuration

### Success Criteria
- Comprehensive plan covering all migration aspects
- Clear Azure service recommendations with justification
- Detailed database migration strategy
- Cost optimization considerations
- Security and compliance requirements addressed
