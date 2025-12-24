# Create Modernization Plan Skill

## Objective
Generate a comprehensive modernization and migration plan for the PhotoAlbum-Java application to migrate from Oracle Database and local Docker deployment to Azure cloud services.

## Context
The PhotoAlbum-Java application is a Spring Boot 2.7.18 application with the following characteristics:
- **Framework**: Spring Boot 2.7.18 (Java 8)
- **Database**: Oracle Database 21c Express Edition
- **Current Storage**: Photos stored as BLOBs in Oracle Database
- **Current Deployment**: Docker/Docker Compose
- **Key Features**: Photo upload, gallery view, photo details, drag-and-drop UI

## Analysis Tasks

### 1. Current Architecture Assessment
- Application uses Spring Boot with JPA/Hibernate
- Oracle Database for structured data and BLOB storage
- Docker-based deployment with docker-compose
- No file system storage (all photos in database)
- Java 8 runtime

### 2. Azure Target Architecture Recommendation

#### Recommended Azure Services:
1. **Compute**: Azure App Service (Linux, Java 8/11)
   - Fully managed PaaS
   - Built-in CI/CD integration
   - Auto-scaling capabilities

2. **Database Options**:
   - **Option A**: Azure Database for PostgreSQL (Recommended)
     - Cost-effective
     - Managed service
     - Easy migration from Oracle
   - **Option B**: Azure SQL Database
     - Alternative if SQL Server compatibility preferred
   
3. **Storage**: Azure Blob Storage
   - Replace database BLOB storage with Azure Blob Storage
   - More scalable and cost-effective for binary data
   - CDN integration possible

4. **Additional Services**:
   - **Azure Container Registry**: For Docker image management
   - **Azure Key Vault**: For secrets management (database credentials, storage keys)
   - **Application Insights**: For monitoring and diagnostics
   - **Azure CDN** (Optional): For photo delivery optimization

### 3. Migration Plan

#### Phase 1: Infrastructure Setup
- [ ] Create Azure Resource Group
- [ ] Set up Azure App Service (Linux, Java)
- [ ] Provision Azure Database for PostgreSQL
- [ ] Create Azure Storage Account for Blob Storage
- [ ] Configure Azure Key Vault for secrets
- [ ] Set up Application Insights

#### Phase 2: Code Changes
- [ ] Update database driver from Oracle JDBC to PostgreSQL
- [ ] Modify application.properties for Azure services
- [ ] Refactor photo storage from database BLOBs to Azure Blob Storage
- [ ] Update PhotoService to use Azure Storage SDK
- [ ] Add Azure Storage dependencies to pom.xml
- [ ] Configure managed identity for secure Azure service access

#### Phase 3: Database Migration
- [ ] Export Oracle database schema
- [ ] Convert Oracle DDL to PostgreSQL DDL
- [ ] Migrate existing photo metadata to PostgreSQL
- [ ] Extract photo BLOBs from Oracle and upload to Azure Blob Storage
- [ ] Update photo records with Azure Blob Storage URLs

#### Phase 4: Configuration & Deployment
- [ ] Create Azure-specific application profiles
- [ ] Set up environment variables in App Service
- [ ] Configure connection strings in Key Vault
- [ ] Create Dockerfile optimized for Azure
- [ ] Set up CI/CD pipeline (GitHub Actions)
- [ ] Deploy application to App Service

#### Phase 5: Testing & Validation
- [ ] Verify photo upload functionality
- [ ] Test photo retrieval from Azure Blob Storage
- [ ] Validate database operations
- [ ] Performance testing
- [ ] Security assessment

#### Phase 6: Optimization
- [ ] Enable Azure CDN for photo delivery
- [ ] Configure auto-scaling rules
- [ ] Set up monitoring and alerts
- [ ] Implement backup strategy
- [ ] Cost optimization review

## Required Code Changes

### 1. pom.xml Updates
```xml
<!-- Remove Oracle JDBC -->
<!-- Add PostgreSQL Driver -->
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <scope>runtime</scope>
</dependency>

<!-- Add Azure Storage SDK -->
<dependency>
    <groupId>com.azure</groupId>
    <artifactId>azure-storage-blob</artifactId>
    <version>12.23.0</version>
</dependency>

<!-- Add Azure Identity for Managed Identity -->
<dependency>
    <groupId>com.azure</groupId>
    <artifactId>azure-identity</artifactId>
    <version>1.10.0</version>
</dependency>
```

### 2. application.properties Changes
```properties
# PostgreSQL Configuration
spring.datasource.url=jdbc:postgresql://${DB_HOST}:5432/${DB_NAME}
spring.datasource.username=${DB_USERNAME}
spring.datasource.password=${DB_PASSWORD}
spring.datasource.driver-class-name=org.postgresql.Driver

# Azure Storage Configuration
azure.storage.account-name=${AZURE_STORAGE_ACCOUNT}
azure.storage.container-name=photos
azure.storage.connection-string=${AZURE_STORAGE_CONNECTION_STRING}

# Application Insights
azure.application-insights.instrumentation-key=${APPINSIGHTS_INSTRUMENTATIONKEY}
```

### 3. Photo Model Changes
Remove BLOB storage, add Azure Blob Storage URL:
```java
// Remove: @Lob private byte[] photoData;
// Add: private String blobUrl;
// Add: private String blobName;
```

### 4. Service Layer Changes
Update PhotoServiceImpl to:
- Upload photos to Azure Blob Storage
- Store blob URL in PostgreSQL
- Retrieve photos from Azure Blob Storage

## Infrastructure as Code

### Bicep/ARM Template Structure
```
infrastructure/
├── main.bicep
├── modules/
│   ├── appService.bicep
│   ├── database.bicep
│   ├── storage.bicep
│   └── keyVault.bicep
└── parameters/
    ├── dev.parameters.json
    └── prod.parameters.json
```

## CI/CD Pipeline

### GitHub Actions Workflow
```yaml
name: Deploy to Azure

on:
  push:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Java
        uses: actions/setup-java@v3
        with:
          java-version: '11'
      - name: Build with Maven
        run: mvn clean package
      - name: Deploy to Azure App Service
        uses: azure/webapps-deploy@v2
        with:
          app-name: photoalbum-app
          package: target/*.jar
```

## Cost Estimation (Monthly)
- Azure App Service (B1): ~$13
- Azure Database for PostgreSQL (Basic): ~$25
- Azure Storage (Hot tier, 10GB): ~$0.50
- Application Insights (Basic): Free tier available
- **Total**: ~$40-50/month (with room for scaling)

## Security Considerations
- Use Managed Identity for service-to-service authentication
- Store secrets in Azure Key Vault
- Enable HTTPS only
- Configure PostgreSQL firewall rules
- Enable Azure Storage private endpoints (production)
- Implement Azure AD authentication (future enhancement)

## Rollback Strategy
- Keep Oracle deployment running until validation complete
- Use Azure deployment slots for zero-downtime deployment
- Maintain database backups
- Version control all infrastructure code

## Success Criteria
- ✅ Application successfully deployed to Azure App Service
- ✅ Photos stored in and retrieved from Azure Blob Storage
- ✅ Database migrated to Azure Database for PostgreSQL
- ✅ All existing functionality working
- ✅ CI/CD pipeline operational
- ✅ Monitoring and alerts configured
- ✅ Cost within expected range

## Next Steps
1. Review and approve this modernization plan
2. Set up Azure subscription and resource group
3. Begin Phase 1: Infrastructure Setup
4. Implement code changes in a feature branch
5. Execute database migration
6. Deploy and test in Azure
7. Cut over from Docker to Azure deployment

## Resources
- [Azure App Service Documentation](https://docs.microsoft.com/azure/app-service/)
- [Azure Database for PostgreSQL](https://docs.microsoft.com/azure/postgresql/)
- [Azure Blob Storage](https://docs.microsoft.com/azure/storage/blobs/)
- [Spring Boot on Azure](https://docs.microsoft.com/azure/developer/java/spring-framework/)
