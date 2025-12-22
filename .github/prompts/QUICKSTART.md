# Quick Start Guide - Azure Migration

This guide helps you get started with the Azure migration of the Photo Album Java application.

## Prerequisites

Before you begin, ensure you have:

- [ ] Azure subscription with Owner or Contributor role
- [ ] Azure CLI installed ([Install Guide](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli))
- [ ] Docker Desktop installed and running
- [ ] Java 8 JDK installed
- [ ] Maven 3.x installed
- [ ] Git installed
- [ ] GitHub account with access to this repository

## Step 1: Review Documentation

1. **Read the Migration Plan**: [appmod-kit.create-plan.prompt.md](./appmod-kit.create-plan.prompt.md)
   - Understand the overall strategy
   - Review timeline and phases
   - Identify your role and responsibilities

2. **Read the AppKit Guide**: [appkit-initialization.md](./appkit-initialization.md)
   - Understand tools and workflows
   - Review assessment results
   - Check best practices

## Step 2: Set Up Local Development Environment

### Install PostgreSQL Locally for Testing

```bash
# Using Docker (Recommended)
docker run --name photo-album-postgres \
  -e POSTGRES_USER=photoalbum \
  -e POSTGRES_PASSWORD=photoalbum \
  -e POSTGRES_DB=photoalbum \
  -p 5432:5432 \
  -d postgres:15

# Verify it's running
docker ps | grep photo-album-postgres

# Connect to verify
docker exec -it photo-album-postgres psql -U photoalbum -d photoalbum
# Type \q to quit
```

### Clone and Set Up Project

```bash
# Clone the repository (if not already done)
git clone https://github.com/showpune/PhotoAlbum-Java.git
cd PhotoAlbum-Java

# Create a feature branch for your work
git checkout -b feature/azure-migration-dev
```

## Step 3: Update Application Dependencies

### 3.1 Update pom.xml

Add PostgreSQL driver dependency:

```xml
<!-- Add after the Oracle JDBC dependency (or replace it) -->
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <scope>runtime</scope>
</dependency>
```

### 3.2 Create New Application Properties for Local PostgreSQL

Create `src/main/resources/application-postgres.properties`:

```properties
# Spring Boot Configuration
server.port=8080

# Character encoding
server.servlet.encoding.charset=UTF-8
server.servlet.encoding.enabled=true
server.servlet.encoding.force=true

# PostgreSQL Database Configuration (Local)
spring.datasource.url=jdbc:postgresql://localhost:5432/photoalbum
spring.datasource.username=photoalbum
spring.datasource.password=photoalbum
spring.datasource.driver-class-name=org.postgresql.Driver

# JPA Configuration for PostgreSQL
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
spring.jpa.hibernate.ddl-auto=create
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true

# File Upload Configuration
spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=50MB

# Application Configuration - File Upload Validation
app.file-upload.max-file-size-bytes=10485760
app.file-upload.allowed-mime-types=image/jpeg,image/png,image/gif,image/webp
app.file-upload.max-files-per-upload=10

# Logging
logging.level.com.photoalbum=DEBUG
logging.level.org.springframework.web=DEBUG
```

### 3.3 Build the Project

```bash
# Build without tests first to verify compilation
mvn clean package -DskipTests

# Run tests
mvn test
```

## Step 4: Test Locally with PostgreSQL

### Start the Application

```bash
# Make sure PostgreSQL container is running
docker ps | grep photo-album-postgres

# Run with PostgreSQL profile
mvn spring-boot:run -Dspring-boot.run.profiles=postgres
```

### Verify Application is Working

1. Open browser: http://localhost:8080
2. Test photo upload
3. View gallery
4. Test photo detail view
5. Test photo deletion

### Check Database

```bash
# Connect to PostgreSQL
docker exec -it photo-album-postgres psql -U photoalbum -d photoalbum

# List tables
\dt

# View photos table structure
\d photos

# Query photos
SELECT id, original_file_name, file_size, uploaded_at FROM photos;

# Exit
\q
```

## Step 5: Azure Login and Setup

### Login to Azure

```bash
# Login to Azure
az login

# List subscriptions
az account list --output table

# Set active subscription
az account set --subscription <subscription-id>

# Verify current subscription
az account show
```

### Run Azure Setup Script

```bash
# Review the script first
cat azure-setup.ps1

# Run the setup script (PowerShell)
pwsh azure-setup.ps1

# Or if on Windows PowerShell
.\azure-setup.ps1
```

The script will create:
- Resource Group
- Azure Container Registry
- Azure Kubernetes Service (AKS)
- Azure Database for PostgreSQL Flexible Server
- Network configuration
- Database user and permissions

**Note**: This will take 15-30 minutes to complete.

### Save Environment Variables

The script creates a `.env` file with connection details:

```bash
# View the environment variables
cat .env

# Example content:
# POSTGRES_SERVER=photo-album-resources-xxx-postgresql.postgres.database.azure.com
# POSTGRES_USER=photoalbum
# POSTGRES_PASSWORD=photoalbum
# POSTGRES_CONNECTION_STRING=jdbc:postgresql://...
# RESOURCE_GROUP=photo-album-resources-xxx
# ACR_NAME=photoalbumacr12345
# AKS_CLUSTER_NAME=photo-album-resources-xxx-aks
# LOCATION=westus3
```

## Step 6: Test with Azure PostgreSQL

### Update Application Properties for Azure

Create `src/main/resources/application-azure.properties`:

```properties
# Spring Boot Configuration
server.port=8080

# Character encoding
server.servlet.encoding.charset=UTF-8
server.servlet.encoding.enabled=true
server.servlet.encoding.force=true

# Azure PostgreSQL Database Configuration
spring.datasource.url=${POSTGRES_CONNECTION_STRING}?sslmode=require
spring.datasource.username=${POSTGRES_USER}
spring.datasource.password=${POSTGRES_PASSWORD}
spring.datasource.driver-class-name=org.postgresql.Driver

# JPA Configuration for PostgreSQL
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=false
spring.jpa.properties.hibernate.format_sql=true

# SSL Configuration for Azure
spring.datasource.hikari.connection-test-query=SELECT 1

# File Upload Configuration
spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=50MB

# Application Configuration
app.file-upload.max-file-size-bytes=10485760
app.file-upload.allowed-mime-types=image/jpeg,image/png,image/gif,image/webp
app.file-upload.max-files-per-upload=10

# Logging
logging.level.com.photoalbum=INFO
logging.level.org.springframework.web=INFO
```

### Test Connection to Azure PostgreSQL

```bash
# Load environment variables from .env
export $(cat .env | xargs)

# Run application with Azure profile
mvn spring-boot:run -Dspring-boot.run.profiles=azure
```

## Step 7: Build and Push Docker Image to ACR

### Build Docker Image

```bash
# Build the Docker image
docker build -t photo-album:latest .

# Test the image locally with PostgreSQL
docker run --name photo-album-test \
  --network host \
  -e SPRING_PROFILES_ACTIVE=postgres \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/photoalbum \
  -e SPRING_DATASOURCE_USERNAME=photoalbum \
  -e SPRING_DATASOURCE_PASSWORD=photoalbum \
  -p 8080:8080 \
  photo-album:latest

# Stop and remove test container
docker stop photo-album-test
docker rm photo-album-test
```

### Push to Azure Container Registry

```bash
# Load ACR name from .env
export $(cat .env | xargs)

# Login to ACR
az acr login --name $ACR_NAME

# Get ACR login server
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer --output tsv)
echo "ACR Login Server: $ACR_LOGIN_SERVER"

# Tag image for ACR
docker tag photo-album:latest $ACR_LOGIN_SERVER/photo-album:latest
docker tag photo-album:latest $ACR_LOGIN_SERVER/photo-album:v1.0.0

# Push to ACR
docker push $ACR_LOGIN_SERVER/photo-album:latest
docker push $ACR_LOGIN_SERVER/photo-album:v1.0.0

# Verify images in ACR
az acr repository list --name $ACR_NAME --output table
az acr repository show-tags --name $ACR_NAME --repository photo-album --output table
```

## Step 8: Deploy to Azure (Coming Soon)

Deployment instructions will be added in the next phase. Options include:
- Azure App Service (Web App for Containers)
- Azure Kubernetes Service (AKS)

## Common Commands Reference

### Docker Commands

```bash
# List running containers
docker ps

# View logs
docker logs photo-album-postgres

# Stop container
docker stop photo-album-postgres

# Start container
docker start photo-album-postgres

# Remove container
docker rm photo-album-postgres
```

### Maven Commands

```bash
# Clean build
mvn clean package

# Skip tests
mvn clean package -DskipTests

# Run tests only
mvn test

# Run specific test
mvn test -Dtest=PhotoServiceTest

# Run with profile
mvn spring-boot:run -Dspring-boot.run.profiles=postgres
```

### Azure CLI Commands

```bash
# List resource groups
az group list --output table

# Show resource group details
az group show --name $RESOURCE_GROUP

# List all resources in resource group
az resource list --resource-group $RESOURCE_GROUP --output table

# Show PostgreSQL server details
az postgres flexible-server show \
  --resource-group $RESOURCE_GROUP \
  --name <server-name>

# List ACR repositories
az acr repository list --name $ACR_NAME --output table
```

## Troubleshooting

### Issue: Can't connect to local PostgreSQL

```bash
# Check if container is running
docker ps | grep postgres

# Check logs
docker logs photo-album-postgres

# Restart container
docker restart photo-album-postgres
```

### Issue: Maven build fails

```bash
# Clean Maven cache
mvn clean

# Update dependencies
mvn dependency:purge-local-repository

# Build with debug output
mvn clean package -X
```

### Issue: Can't connect to Azure PostgreSQL

```bash
# Check firewall rules
az postgres flexible-server firewall-rule list \
  --resource-group $RESOURCE_GROUP \
  --name <server-name>

# Add your current IP
CURRENT_IP=$(curl -s https://api.ipify.org)
az postgres flexible-server firewall-rule create \
  --resource-group $RESOURCE_GROUP \
  --name <server-name> \
  --rule-name AllowMyIP \
  --start-ip-address $CURRENT_IP \
  --end-ip-address $CURRENT_IP
```

### Issue: Docker image push to ACR fails

```bash
# Re-login to ACR
az acr login --name $ACR_NAME

# Check ACR status
az acr show --name $ACR_NAME --query "{Name:name, Status:provisioningState}"

# Enable admin user (if needed)
az acr update --name $ACR_NAME --admin-enabled true
```

## Next Steps

After completing this quick start:

1. ✅ Commit your changes
2. ✅ Push to GitHub
3. ✅ Create pull request
4. 📋 Review with team
5. 📋 Set up CI/CD pipeline (GitHub Actions)
6. 📋 Deploy to staging environment
7. 📋 Perform testing
8. 📋 Deploy to production

## Getting Help

- **Documentation**: Check the [Migration Plan](./appmod-kit.create-plan.prompt.md)
- **Tools**: Review [AppKit Guide](./appkit-initialization.md)
- **Issues**: Create a GitHub issue
- **Azure Support**: https://azure.microsoft.com/support/

## Checklist

Use this checklist to track your progress:

### Development Setup
- [ ] Azure CLI installed
- [ ] Docker Desktop running
- [ ] Java 8 JDK installed
- [ ] Maven installed
- [ ] PostgreSQL running locally
- [ ] Project builds successfully
- [ ] Application runs locally with PostgreSQL
- [ ] Tests pass

### Azure Setup
- [ ] Azure subscription access
- [ ] Logged in with Azure CLI
- [ ] Ran azure-setup.ps1 script
- [ ] .env file created
- [ ] Can connect to Azure PostgreSQL
- [ ] Application runs with Azure PostgreSQL

### Docker & ACR
- [ ] Docker image builds
- [ ] Image runs locally
- [ ] Logged in to ACR
- [ ] Image pushed to ACR
- [ ] Image visible in ACR

### Ready for Deployment
- [ ] All tests passing
- [ ] Code reviewed
- [ ] Documentation updated
- [ ] Ready for staging deployment

---

**Happy Migrating! 🚀**

For questions or issues, contact the migration team or create a GitHub issue.
