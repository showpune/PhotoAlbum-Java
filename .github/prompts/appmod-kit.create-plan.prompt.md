# AppMod Kit - Azure Migration Plan Creation Guide

## Overview
This guide provides instructions for creating a migration plan to deploy the Photo Album Java application to Azure using the Application Modernization (AppMod) toolkit.

## Project Information

**Application Name:** Photo Album Java  
**Technology Stack:**
- Framework: Spring Boot 2.7.18
- Language: Java 8
- Database: Oracle Database (currently using Docker container)
- Build Tool: Maven
- Current Deployment: Docker Compose with Oracle DB

## Current Architecture

### Services
1. **photoalbum-java-app**: Spring Boot web application
   - Port: 8080
   - Dependencies: Oracle Database
   - Features: Photo upload, gallery view, photo management

2. **oracle-db**: Oracle Database Free 23ai
   - Port: 1521
   - Database: FREEPDB1
   - User: photoalbum
   - Schema: Photos table with BLOB storage

### Key Dependencies
- Oracle Database (Backend service)
- File upload capabilities (max 10MB, multiple image formats)
- BLOB storage for photos
- JPA/Hibernate for ORM

## Azure Migration Plan Steps

### Step 1: Analyze Repository Structure
Use the `appmod-analyze-repository` tool to detect technologies and dependencies:

```
Tool: appmod-analyze-repository
Parameters:
  - repositoryPath: /home/runner/work/PhotoAlbum-Java/PhotoAlbum-Java
  - depth: 3
  - includeTests: true
```

### Step 2: Generate Deployment Plan
Use the `appmod-get-plan` tool to create a comprehensive Azure deployment plan:

```
Tool: appmod-get-plan
Parameters:
  - workspaceFolder: /home/runner/work/PhotoAlbum-Java/PhotoAlbum-Java
  - projectName: PhotoAlbum-Java
  - services:
    - name: photoalbum-java-app
      path: /home/runner/work/PhotoAlbum-Java/PhotoAlbum-Java
      language: java
      azureComputeHost: containerapp (or appservice)
      dependencies: 
        - azuredatabaseforpostgresql (recommended) or azuredatabaseformysql
        - azurestorageaccount (for blob storage alternative)
        - azurecontainerregistry (for container images)
  - languages: [java]
  - provisioningTool: azd
  - sourceType: from-project
  - deployOption: deploy-and-provision
  - iacOptions: bicep
```

### Step 3: Containerization
If not already containerized properly for Azure:
- Use `appmod-get-containerization-plan` to optimize Dockerfile for Azure
- Ensure compatibility with Azure Container Registry

### Step 4: Generate Architecture Diagram
Use `appmod-generate-architecture-diagram` to visualize the Azure architecture:

```
Tool: appmod-generate-architecture-diagram
Parameters:
  - workspaceFolder: /home/runner/work/PhotoAlbum-Java/PhotoAlbum-Java
  - projectName: PhotoAlbum-Java
  - services: (from analysis)
```

### Step 5: Infrastructure as Code
Generate Bicep files for Azure resources:
- Use `appmod-get-iac-rules` to ensure best practices
- Resources needed:
  - Azure Container Apps or Azure App Service
  - Azure Database for PostgreSQL (recommended over Oracle for cost/simplicity)
  - Azure Container Registry
  - Azure Storage Account (optional, for blob storage)
  - Azure Key Vault (for secrets)
  - Application Insights (for monitoring)

### Step 6: CI/CD Pipeline
Use `appmod-get-cicd-pipeline-guidance` to create GitHub Actions workflow:

```
Tool: appmod-get-cicd-pipeline-guidance
Parameters:
  - workspaceFolder: /home/runner/work/PhotoAlbum-Java/PhotoAlbum-Java
  - useAZDPipelineConfig: true
```

## Recommended Azure Services

### Compute Options
1. **Azure Container Apps** (Recommended)
   - Serverless container hosting
   - Auto-scaling capabilities
   - Cost-effective for variable workloads

2. **Azure App Service**
   - Fully managed PaaS
   - Built-in CI/CD integration
   - Easy deployment from containers

### Database Options
1. **Azure Database for PostgreSQL** (Recommended)
   - More cost-effective than Oracle
   - Fully managed
   - Compatible with JPA/Hibernate (minimal code changes)

2. **Azure Database for MySQL**
   - Alternative option
   - Also fully managed and cost-effective

3. **Azure SQL Database**
   - Enterprise-grade option
   - Requires moderate code changes

### Storage Options
1. **Azure Blob Storage**
   - Store photos as blobs instead of DB BLOBs
   - More scalable and cost-effective
   - Better performance for large files

2. **Continue with DB BLOBs**
   - Keep current architecture
   - Simpler migration path

## Migration Considerations

### Code Changes Required
1. **Database Migration (if switching from Oracle)**
   - Update `application.properties` with Azure database connection string
   - Change JDBC driver dependency in `pom.xml`
   - Update Hibernate dialect
   - Test and validate schema compatibility

2. **Externalize Configuration**
   - Move sensitive data to Azure Key Vault
   - Use Azure App Configuration for application settings
   - Update connection strings for Azure services

3. **Storage Changes (Optional)**
   - Integrate Azure Blob Storage SDK if moving away from DB BLOBs
   - Update PhotoService implementation
   - Modify upload/retrieval logic

### Security Enhancements
1. **Managed Identity**
   - Use Azure Managed Identity for database authentication
   - No hardcoded credentials

2. **Key Vault Integration**
   - Store database passwords, connection strings
   - Integrate with Spring Boot

3. **Network Security**
   - Virtual Network integration
   - Private endpoints for database

## Execution Order

1. Run `appmod-analyze-repository` to understand the project
2. Run `appmod-get-plan` to generate deployment plan
3. Review and confirm the plan (stored in `.azure/plan.copilotmd`)
4. Run `appmod-get-containerization-plan` if needed
5. Run `appmod-generate-architecture-diagram` to visualize
6. Use `appmod-get-iac-rules` to generate infrastructure code
7. Run `appmod-get-cicd-pipeline-guidance` for deployment automation
8. Execute deployment using `azd` tool
9. Run `appmod-summarize-result` to document the migration

## Success Criteria

- [ ] Application successfully running on Azure
- [ ] Database migrated and functional
- [ ] Photos can be uploaded and displayed
- [ ] CI/CD pipeline configured and working
- [ ] Infrastructure as Code (Bicep) files generated
- [ ] Architecture diagram created
- [ ] Documentation updated with Azure deployment instructions
- [ ] Security best practices implemented

## Output Files Expected

- `.azure/plan.copilotmd` - Deployment plan
- `.azure/*.bicep` - Infrastructure as Code files
- `.github/workflows/*.yml` - CI/CD pipeline
- `azure.yaml` - Azure Developer CLI configuration
- Architecture diagram image
- Updated README with Azure deployment instructions

## Notes

- The current Oracle Database setup should be migrated to a managed Azure database service
- Photo storage in BLOBs should be evaluated - Azure Blob Storage may be more cost-effective at scale
- Ensure proper resource sizing for cost optimization
- Consider using Azure Front Door or CDN for better photo delivery performance
- Implement Azure Monitor and Application Insights for observability
