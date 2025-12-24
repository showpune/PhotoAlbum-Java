# PhotoAlbum-Java Azure Migration Plan

**Date**: December 24, 2025  
**Project**: PhotoAlbum-Java  
**Objective**: Migrate from Oracle Database + Docker deployment to Azure cloud services

---

## Executive Summary

This document outlines the comprehensive migration plan for the PhotoAlbum-Java application from a local Docker-based deployment with Oracle Database to a fully cloud-native Azure deployment. The migration will modernize the application architecture while maintaining all existing functionality.

### Current State
- **Application**: Spring Boot 2.7.18 (Java 8)
- **Database**: Oracle Database 21c Express Edition
- **Storage**: Photos stored as BLOBs in Oracle Database
- **Deployment**: Docker Compose (local/on-premises)

### Target State
- **Compute**: Azure App Service (Linux)
- **Database**: Azure Database for PostgreSQL
- **Storage**: Azure Blob Storage
- **Deployment**: CI/CD via GitHub Actions
- **Monitoring**: Application Insights

---

## Architecture Comparison

### Current Architecture
```
┌─────────────────────────────────────────┐
│     Docker Compose Environment          │
│                                         │
│  ┌─────────────────┐  ┌──────────────┐ │
│  │  Spring Boot    │  │   Oracle DB   │ │
│  │  Application    │─▶│   (BLOBs)    │ │
│  │  (Port 8080)    │  │   (Port 1521) │ │
│  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────┘
```

### Target Azure Architecture
```
┌────────────────────────────────────────────────────────────┐
│                     Azure Cloud                            │
│                                                            │
│  ┌──────────────────┐      ┌─────────────────────────┐   │
│  │  Azure App       │      │  Azure Database for     │   │
│  │  Service         │─────▶│  PostgreSQL             │   │
│  │  (Java 11)       │      │  (Metadata)             │   │
│  └────────┬─────────┘      └─────────────────────────┘   │
│           │                                                │
│           │                                                │
│           ▼                                                │
│  ┌──────────────────┐      ┌─────────────────────────┐   │
│  │  Azure Blob      │      │  Application Insights   │   │
│  │  Storage         │      │  (Monitoring)           │   │
│  │  (Photos)        │      └─────────────────────────┘   │
│  └──────────────────┘                                     │
│           │                 ┌─────────────────────────┐   │
│           │                 │  Azure Key Vault        │   │
│           │                 │  (Secrets)              │   │
│           │                 └─────────────────────────┘   │
└────────────────────────────────────────────────────────────┘
```

---

## Phase 1: Infrastructure Setup

### 1.1 Azure Resources to Create

#### Resource Group
- **Name**: `rg-photoalbum-prod`
- **Location**: East US (or preferred region)

#### Azure App Service
- **Name**: `app-photoalbum-prod`
- **Plan**: Linux B1 (scalable to P1v2 if needed)
- **Runtime**: Java 11 (upgrade from Java 8)
- **Configuration**:
  - Always On: Enabled
  - HTTPS Only: Enabled
  - Managed Identity: System-assigned

#### Azure Database for PostgreSQL
- **Name**: `psql-photoalbum-prod`
- **Tier**: Basic (1 vCore, 50GB storage)
- **Version**: PostgreSQL 14
- **Configuration**:
  - Database Name: `photoalbum`
  - Admin Username: `photoalbumadmin`
  - SSL Enforcement: Enabled
  - Firewall: Allow Azure Services

#### Azure Storage Account
- **Name**: `stphotoalbumprod`
- **Performance**: Standard
- **Replication**: LRS (Locally Redundant)
- **Containers**:
  - `photos` (Private access, for photo storage)

#### Azure Key Vault
- **Name**: `kv-photoalbum-prod`
- **Secrets to Store**:
  - `DatabaseConnectionString`
  - `StorageConnectionString`
  - `ApplicationInsightsKey`

#### Application Insights
- **Name**: `appi-photoalbum-prod`
- **Type**: Java
- **Workspace-based**: Yes

### 1.2 Infrastructure as Code (Bicep)

Create `infrastructure/main.bicep`:

```bicep
param location string = resourceGroup().location
param appName string = 'photoalbum'
param environment string = 'prod'

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: 'asp-${appName}-${environment}'
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

// App Service
resource appService 'Microsoft.Web/sites@2022-03-01' = {
  name: 'app-${appName}-${environment}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'JAVA|11-java11'
      alwaysOn: true
      ftpsState: 'Disabled'
    }
    httpsOnly: true
  }
}

// PostgreSQL Server
resource postgresServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = {
  name: 'psql-${appName}-${environment}'
  location: location
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
  }
  properties: {
    version: '14'
    administratorLogin: 'photoalbumadmin'
    administratorLoginPassword: 'P@ssw0rd123!' // Use Key Vault reference
    storage: {
      storageSizeGB: 32
    }
  }
}

// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'st${appName}${environment}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
  }
}

// Blob Container
resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  name: '${storageAccount.name}/default/photos'
  properties: {
    publicAccess: 'None'
  }
}
```

### 1.3 Deployment Commands

```bash
# Create resource group
az group create --name rg-photoalbum-prod --location eastus

# Deploy infrastructure
az deployment group create \
  --resource-group rg-photoalbum-prod \
  --template-file infrastructure/main.bicep \
  --parameters environment=prod
```

---

## Phase 2: Code Modifications

### 2.1 Update pom.xml

**Remove:**
```xml
<dependency>
    <groupId>com.oracle.database.jdbc</groupId>
    <artifactId>ojdbc8</artifactId>
    <scope>runtime</scope>
</dependency>
```

**Add:**
```xml
<!-- PostgreSQL Driver -->
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <scope>runtime</scope>
</dependency>

<!-- Azure Storage Blob SDK -->
<dependency>
    <groupId>com.azure</groupId>
    <artifactId>azure-storage-blob</artifactId>
    <version>12.23.0</version>
</dependency>

<!-- Azure Identity (for Managed Identity) -->
<dependency>
    <groupId>com.azure</groupId>
    <artifactId>azure-identity</artifactId>
    <version>1.10.0</version>
</dependency>

<!-- Application Insights -->
<dependency>
    <groupId>com.microsoft.azure</groupId>
    <artifactId>applicationinsights-spring-boot-starter</artifactId>
    <version>2.6.4</version>
</dependency>
```

### 2.2 Update Photo Entity

**File**: `src/main/java/com/photoalbum/model/Photo.java`

**Current:**
```java
@Lob
@Column(name = "PHOTO_DATA", nullable = false)
private byte[] photoData;
```

**Updated:**
```java
@Column(name = "blob_url", length = 500)
private String blobUrl;

@Column(name = "blob_name", length = 255)
private String blobName;

// Remove photoData field entirely
```

### 2.3 Create Azure Storage Service

**New File**: `src/main/java/com/photoalbum/service/AzureBlobStorageService.java`

```java
package com.photoalbum.service;

import com.azure.storage.blob.BlobClient;
import com.azure.storage.blob.BlobContainerClient;
import com.azure.storage.blob.BlobServiceClient;
import com.azure.storage.blob.BlobServiceClientBuilder;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.UUID;

@Service
public class AzureBlobStorageService {

    private final BlobContainerClient containerClient;

    public AzureBlobStorageService(
            @Value("${azure.storage.connection-string}") String connectionString,
            @Value("${azure.storage.container-name}") String containerName) {
        BlobServiceClient blobServiceClient = new BlobServiceClientBuilder()
                .connectionString(connectionString)
                .buildClient();
        this.containerClient = blobServiceClient.getBlobContainerClient(containerName);
    }

    public String uploadPhoto(MultipartFile file) throws IOException {
        String blobName = UUID.randomUUID().toString() + "-" + file.getOriginalFilename();
        BlobClient blobClient = containerClient.getBlobClient(blobName);
        blobClient.upload(file.getInputStream(), file.getSize(), true);
        return blobClient.getBlobUrl();
    }

    public byte[] downloadPhoto(String blobName) {
        BlobClient blobClient = containerClient.getBlobClient(blobName);
        return blobClient.downloadContent().toBytes();
    }

    public void deletePhoto(String blobName) {
        BlobClient blobClient = containerClient.getBlobClient(blobName);
        blobClient.delete();
    }
}
```

### 2.4 Update PhotoServiceImpl

**File**: `src/main/java/com/photoalbum/service/impl/PhotoServiceImpl.java`

Modify to use `AzureBlobStorageService` instead of storing photos in database:

```java
@Autowired
private AzureBlobStorageService azureBlobStorageService;

// In savePhoto method:
String blobUrl = azureBlobStorageService.uploadPhoto(file);
photo.setBlobUrl(blobUrl);
photo.setBlobName(extractBlobNameFromUrl(blobUrl));
// Remove: photo.setPhotoData(file.getBytes());

// In getPhotoData method:
return azureBlobStorageService.downloadPhoto(photo.getBlobName());
```

### 2.5 Update application.properties

**Create**: `src/main/resources/application-azure.properties`

```properties
# PostgreSQL Configuration
spring.datasource.url=jdbc:postgresql://${DB_HOST:localhost}:5432/${DB_NAME:photoalbum}
spring.datasource.username=${DB_USERNAME:photoalbumadmin}
spring.datasource.password=${DB_PASSWORD}
spring.datasource.driver-class-name=org.postgresql.Driver

# JPA/Hibernate Configuration
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=false
spring.jpa.properties.hibernate.format_sql=true

# Azure Storage Configuration
azure.storage.account-name=${AZURE_STORAGE_ACCOUNT}
azure.storage.container-name=photos
azure.storage.connection-string=${AZURE_STORAGE_CONNECTION_STRING}

# Application Insights
azure.application-insights.instrumentation-key=${APPINSIGHTS_INSTRUMENTATIONKEY}

# Server Configuration
server.port=8080
server.compression.enabled=true

# File Upload Configuration
spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=10MB
```

---

## Phase 3: Database Migration

### 3.1 Export Oracle Schema

```sql
-- Connect to Oracle
sqlplus photoalbum/photoalbum@localhost:1521/XE

-- Export schema
SELECT dbms_metadata.get_ddl('TABLE', 'PHOTOS') FROM dual;

-- Export data
SELECT * FROM PHOTOS;
```

### 3.2 Convert to PostgreSQL

**PostgreSQL Schema**:

```sql
CREATE TABLE photos (
    id VARCHAR(36) PRIMARY KEY,
    original_file_name VARCHAR(255) NOT NULL,
    stored_file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500),
    file_size BIGINT NOT NULL,
    mime_type VARCHAR(50) NOT NULL,
    uploaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    width INTEGER,
    height INTEGER,
    blob_url VARCHAR(500),
    blob_name VARCHAR(255)
);

CREATE INDEX idx_photos_uploaded_at ON photos(uploaded_at);
```

### 3.3 Migration Script

**Create**: `scripts/migrate-to-azure.sh`

```bash
#!/bin/bash

# Step 1: Export photos from Oracle and upload to Azure Blob Storage
# Step 2: Export metadata to CSV
# Step 3: Import metadata to PostgreSQL

echo "Starting migration..."

# Export Oracle data
sqlplus -s photoalbum/photoalbum@localhost:1521/XE <<EOF > photos_export.csv
SET PAGESIZE 0
SET LINESIZE 1000
SET FEEDBACK OFF
SET HEADING OFF
SELECT id || ',' || original_file_name || ',' || stored_file_name || ',' || 
       file_size || ',' || mime_type || ',' || uploaded_at || ',' || 
       width || ',' || height
FROM photos;
EXIT;
EOF

echo "Data exported to photos_export.csv"
```

---

## Phase 4: CI/CD Pipeline

### 4.1 GitHub Actions Workflow

**Create**: `.github/workflows/azure-deploy.yml`

```yaml
name: Deploy to Azure App Service

on:
  push:
    branches: [ main ]
  workflow_dispatch:

env:
  AZURE_WEBAPP_NAME: app-photoalbum-prod
  JAVA_VERSION: '11'

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Java
      uses: actions/setup-java@v3
      with:
        java-version: ${{ env.JAVA_VERSION }}
        distribution: 'microsoft'
    
    - name: Build with Maven
      run: mvn clean package -DskipTests
    
    - name: Login to Azure
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}
    
    - name: Deploy to Azure App Service
      uses: azure/webapps-deploy@v2
      with:
        app-name: ${{ env.AZURE_WEBAPP_NAME }}
        package: target/*.jar
    
    - name: Logout from Azure
      run: az logout
```

### 4.2 Required GitHub Secrets

- `AZURE_CREDENTIALS`: Service principal credentials
- `DB_PASSWORD`: PostgreSQL password
- `AZURE_STORAGE_CONNECTION_STRING`: Storage account connection string

---

## Phase 5: Testing Strategy

### 5.1 Pre-Migration Testing
- [ ] Document all existing functionality
- [ ] Create test photo dataset
- [ ] Record performance baseline

### 5.2 Post-Migration Testing
- [ ] Photo upload functionality
- [ ] Photo retrieval and display
- [ ] Photo deletion
- [ ] Gallery navigation
- [ ] Photo detail view
- [ ] Performance comparison
- [ ] Load testing

### 5.3 Test Checklist

```
✅ Upload single photo
✅ Upload multiple photos (drag-and-drop)
✅ View photo gallery
✅ Click photo to view details
✅ Navigate between photos (Previous/Next)
✅ Delete photo from gallery
✅ Delete photo from detail view
✅ Verify photo metadata (size, dimensions, date)
✅ Test file type validation
✅ Test file size validation (10MB limit)
✅ Verify responsive design
✅ Check browser caching behavior
```

---

## Phase 6: Cutover Plan

### 6.1 Pre-Cutover
- [ ] Complete code migration
- [ ] Deploy to Azure staging environment
- [ ] Run full test suite
- [ ] Migrate database
- [ ] Verify all Azure resources provisioned
- [ ] Update DNS (if applicable)

### 6.2 Cutover Steps
1. **Freeze Oracle database** (read-only mode)
2. **Final data sync** to PostgreSQL and Azure Blob Storage
3. **Update App Service configuration** with production settings
4. **Deploy final build** to App Service
5. **Smoke test** critical paths
6. **Enable monitoring alerts**
7. **Announce migration complete**

### 6.3 Rollback Plan
- Keep Oracle environment running for 30 days
- Azure deployment slots for quick rollback
- Database backups before migration
- Document rollback procedure

---

## Cost Analysis

### Monthly Azure Costs (Estimated)

| Service | Tier | Monthly Cost |
|---------|------|--------------|
| App Service | B1 Basic | $13.14 |
| PostgreSQL | Basic (1 vCore, 32GB) | $24.82 |
| Storage Account | Standard LRS (10GB) | $0.50 |
| Application Insights | Basic (5GB) | Free |
| Key Vault | Standard | $0.03 |
| **Total** | | **~$38.49** |

### Cost Optimization Tips
- Use Azure Reserved Instances for 30-40% savings
- Enable auto-scaling only when needed
- Use Azure Cost Management alerts
- Archive old photos to Cool/Archive storage tier

---

## Security Checklist

- [ ] Enable HTTPS only on App Service
- [ ] Configure PostgreSQL firewall rules
- [ ] Use Managed Identity for Azure service authentication
- [ ] Store all secrets in Key Vault
- [ ] Enable Azure Storage private endpoints (production)
- [ ] Implement Azure AD authentication (future)
- [ ] Enable Application Insights security monitoring
- [ ] Regular security patch updates
- [ ] Enable database SSL connections
- [ ] Configure CORS policies

---

## Monitoring and Alerts

### Application Insights Metrics
- Request rate and response time
- Failed requests
- Dependency calls (database, storage)
- Custom events (photo uploads, deletions)

### Alerts to Configure
- App Service CPU > 80%
- App Service Memory > 80%
- PostgreSQL connection failures
- Storage account throttling
- Application errors > threshold

---

## Timeline

| Phase | Duration | Dependencies |
|-------|----------|--------------|
| Phase 1: Infrastructure Setup | 1-2 days | Azure subscription |
| Phase 2: Code Modifications | 3-5 days | Phase 1 complete |
| Phase 3: Database Migration | 2-3 days | Phase 2 complete |
| Phase 4: CI/CD Pipeline | 1-2 days | Phase 2 complete |
| Phase 5: Testing | 3-5 days | Phase 3 complete |
| Phase 6: Cutover | 1 day | All phases complete |
| **Total** | **11-18 days** | |

---

## Success Criteria

✅ **Functional Requirements**
- All existing features work in Azure
- No data loss during migration
- Photo upload/download performance acceptable

✅ **Non-Functional Requirements**
- Application availability > 99.5%
- Page load time < 3 seconds
- Photo upload time < 5 seconds
- Cost within budget ($40-50/month)

✅ **Technical Requirements**
- CI/CD pipeline operational
- Monitoring and alerts configured
- Security best practices implemented
- Documentation complete

---

## Next Steps

1. **Review and Approve**: Review this plan with stakeholders
2. **Azure Setup**: Create Azure subscription and resource group
3. **Development Branch**: Create feature branch for Azure migration
4. **Phase 1**: Execute infrastructure setup
5. **Phase 2**: Implement code changes
6. **Phase 3**: Perform database migration
7. **Phase 4**: Set up CI/CD
8. **Phase 5**: Complete testing
9. **Phase 6**: Execute cutover

---

## References

- [Azure App Service for Java](https://docs.microsoft.com/azure/app-service/quickstart-java)
- [Azure Database for PostgreSQL](https://docs.microsoft.com/azure/postgresql/)
- [Azure Blob Storage Java SDK](https://docs.microsoft.com/azure/storage/blobs/storage-quickstart-blobs-java)
- [Spring Boot on Azure](https://docs.microsoft.com/azure/developer/java/spring-framework/)
- [Oracle to PostgreSQL Migration Guide](https://docs.microsoft.com/azure/postgresql/howto-migrate-from-oracle)

---

**Document Version**: 1.0  
**Last Updated**: December 24, 2025  
**Author**: Azure Migration Team
