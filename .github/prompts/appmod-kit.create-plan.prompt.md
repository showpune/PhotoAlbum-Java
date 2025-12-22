# Photo Album Application - Azure Migration Plan

## Overview
This document provides instructions for migrating the Photo Album Java Spring Boot application from a local Docker-based deployment to Azure cloud services.

## Application Architecture

### Current State (Local/Docker)
- **Application**: Java Spring Boot 2.7.18 (Java 8)
- **Database**: Oracle Database 21c Express Edition
- **Deployment**: Docker Compose with two containers
- **Storage**: Photos stored as BLOBs in Oracle Database
- **Port**: Application runs on port 8080

### Technology Stack
- Spring Boot Web
- Spring Data JPA
- Thymeleaf templating
- Oracle JDBC Driver
- Maven build tool
- Bootstrap 5 frontend

## Azure Migration Strategy

### Recommended Azure Services

#### 1. Compute Service
**Azure Container Apps** (Recommended)
- Serverless container platform
- Automatic scaling based on HTTP traffic
- Built-in load balancing
- Simple deployment from Docker containers
- Cost-effective for variable workloads

**Alternative**: Azure App Service
- Platform-as-a-Service (PaaS) for web applications
- Built-in CI/CD capabilities
- Easy integration with Azure services

#### 2. Database Service
**Azure Database for PostgreSQL** (Recommended Migration Path)
- Fully managed relational database
- High availability and automatic backups
- Compatible with Spring Data JPA
- More cost-effective than Oracle on Azure

**Alternative**: Oracle Database on Azure
- Oracle Database on Azure Virtual Machines
- Oracle Autonomous Database on Azure
- Maintains Oracle compatibility but higher cost

#### 3. Storage Service
**Azure Blob Storage** (Recommended for Photos)
- Scalable object storage for images
- CDN integration for fast delivery
- Lifecycle management for cost optimization
- More efficient than database BLOB storage at scale

#### 4. Supporting Services
- **Azure Container Registry (ACR)**: Store Docker images
- **Azure Key Vault**: Secure storage for connection strings and secrets
- **Azure Application Insights**: Application monitoring and diagnostics
- **Azure CDN**: Content delivery for static assets and images
- **Azure Virtual Network**: Network isolation and security

## Migration Steps

### Phase 1: Preparation
1. **Repository Analysis**
   - Analyze current application structure
   - Identify dependencies on Oracle-specific features
   - Document configuration requirements

2. **Azure Resource Planning**
   - Determine target Azure region
   - Plan resource naming conventions
   - Design network architecture
   - Estimate costs

### Phase 2: Database Migration
1. **Option A: Migrate to PostgreSQL**
   - Create Azure Database for PostgreSQL Flexible Server
   - Update Spring Boot dependencies (replace ojdbc8 with postgresql driver)
   - Update application.properties for PostgreSQL
   - Test database schema generation with Hibernate
   - Migrate existing data using Azure Database Migration Service

2. **Option B: Keep Oracle**
   - Provision Oracle Database on Azure VM or use Oracle Autonomous Database
   - Configure network connectivity
   - Migrate database using Oracle Data Pump or RMAN

### Phase 3: Application Containerization
1. **Dockerfile Optimization**
   - Review existing Dockerfile
   - Optimize for Azure Container Registry
   - Add health check endpoints
   - Configure environment-based configuration

2. **Storage Refactoring (Recommended)**
   - Migrate from database BLOB storage to Azure Blob Storage
   - Update PhotoService to use Azure Storage SDK
   - Implement connection string configuration via environment variables
   - Test upload and retrieval operations

### Phase 4: Infrastructure as Code
1. **Create Bicep/Terraform Templates**
   - Define Azure Container Apps environment
   - Configure database resources
   - Set up Azure Blob Storage account
   - Create Azure Container Registry
   - Configure Key Vault for secrets
   - Set up Application Insights

2. **Configure Networking**
   - Virtual Network for services
   - Private endpoints for database
   - Public endpoint for Container App

### Phase 5: CI/CD Pipeline
1. **GitHub Actions Workflow**
   - Build and test Java application
   - Build Docker image
   - Push to Azure Container Registry
   - Deploy to Azure Container Apps
   - Run smoke tests

2. **Environment Configuration**
   - Development environment
   - Production environment
   - Environment-specific configuration

### Phase 6: Deployment and Testing
1. **Initial Deployment**
   - Deploy infrastructure using IaC
   - Deploy application container
   - Configure custom domain (optional)
   - Set up SSL/TLS certificates

2. **Testing**
   - Functional testing of all features
   - Performance testing
   - Security testing
   - Load testing

3. **Monitoring Setup**
   - Configure Application Insights
   - Set up alerts and dashboards
   - Configure log analytics

## Configuration Changes Required

### Database Configuration
**For PostgreSQL Migration:**
```properties
# PostgreSQL Configuration
spring.datasource.url=jdbc:postgresql://${DB_HOST}:5432/${DB_NAME}
spring.datasource.username=${DB_USERNAME}
spring.datasource.password=${DB_PASSWORD}
spring.datasource.driver-class-name=org.postgresql.Driver
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
```

### Azure Blob Storage Configuration
```properties
# Azure Storage Configuration
azure.storage.account-name=${AZURE_STORAGE_ACCOUNT_NAME}
azure.storage.account-key=${AZURE_STORAGE_ACCOUNT_KEY}
azure.storage.container-name=photos
azure.storage.blob-endpoint=${AZURE_STORAGE_BLOB_ENDPOINT}
```

### Application Insights
```properties
# Application Insights
azure.application-insights.instrumentation-key=${APPINSIGHTS_INSTRUMENTATIONKEY}
```

## Dependencies to Add

### For PostgreSQL
```xml
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <scope>runtime</scope>
</dependency>
```

### For Azure Blob Storage
```xml
<dependency>
    <groupId>com.azure</groupId>
    <artifactId>azure-storage-blob</artifactId>
    <version>12.25.0</version>
</dependency>
```

### For Application Insights
```xml
<dependency>
    <groupId>com.microsoft.azure</groupId>
    <artifactId>applicationinsights-spring-boot-starter</artifactId>
    <version>2.6.4</version>
</dependency>
```

## Security Considerations

1. **Secrets Management**
   - Store all credentials in Azure Key Vault
   - Use Managed Identity for Azure service authentication
   - Never hardcode connection strings

2. **Network Security**
   - Use private endpoints for database
   - Restrict Container App ingress to HTTPS only
   - Implement network security groups

3. **Application Security**
   - Enable HTTPS enforcement
   - Implement authentication/authorization
   - Configure CORS policies
   - Input validation and sanitization

## Cost Optimization

1. **Right-sizing Resources**
   - Start with appropriate tier for Container Apps
   - Use Flexible Server for PostgreSQL (more cost-effective)
   - Implement auto-scaling policies

2. **Storage Optimization**
   - Use appropriate Blob Storage tier (Hot/Cool)
   - Implement lifecycle policies
   - Enable CDN caching

3. **Monitoring and Alerts**
   - Set up cost alerts
   - Monitor resource utilization
   - Review and optimize regularly

## Rollback Plan

1. **Database Backup**
   - Take full backup before migration
   - Test restore procedures

2. **Application Rollback**
   - Keep previous container image version
   - Document rollback procedures
   - Test rollback process

## Success Criteria

1. **Functionality**
   - All features working in Azure
   - Photo upload and retrieval functional
   - Gallery view working correctly
   - Delete functionality operational

2. **Performance**
   - Page load time comparable to local deployment
   - Photo upload time acceptable
   - Database queries performing well

3. **Reliability**
   - Application remains available
   - Auto-scaling working as expected
   - Error handling functioning properly

4. **Security**
   - All secrets properly secured
   - HTTPS enforced
   - No security vulnerabilities

## Post-Migration Tasks

1. **Documentation**
   - Update README with Azure deployment instructions
   - Document configuration settings
   - Create runbooks for common operations

2. **Monitoring**
   - Set up regular health checks
   - Configure alerting for critical issues
   - Review logs and metrics

3. **Optimization**
   - Review performance metrics
   - Optimize resource allocation
   - Implement caching strategies

## Tools and Commands

### Azure CLI
```bash
# Login to Azure
az login

# Create resource group
az group create --name photoalbum-rg --location eastus

# Deploy using Bicep
az deployment group create --resource-group photoalbum-rg --template-file main.bicep

# View logs
az containerapp logs show --name photoalbum-app --resource-group photoalbum-rg
```

### Build and Deploy
```bash
# Build Docker image
docker build -t photoalbum-java:latest .

# Tag for ACR
docker tag photoalbum-java:latest <acr-name>.azurecr.io/photoalbum-java:latest

# Push to ACR
az acr login --name <acr-name>
docker push <acr-name>.azurecr.io/photoalbum-java:latest
```

## References

- [Azure Container Apps Documentation](https://docs.microsoft.com/azure/container-apps/)
- [Azure Database for PostgreSQL](https://docs.microsoft.com/azure/postgresql/)
- [Azure Blob Storage](https://docs.microsoft.com/azure/storage/blobs/)
- [Spring Boot on Azure](https://docs.microsoft.com/azure/developer/java/spring-framework/)
- [Azure Application Insights](https://docs.microsoft.com/azure/azure-monitor/app/app-insights-overview)
