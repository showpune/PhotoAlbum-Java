# PhotoAlbum-Java - Azure Migration Documentation

This directory contains all documentation and planning files for migrating the PhotoAlbum-Java application to Azure.

## Directory Contents

### Planning Documents

**plan.copilotmd**
- Complete Azure deployment plan
- Resource recommendations and configurations
- Step-by-step execution instructions
- Migration strategy from Oracle to PostgreSQL
- Storage migration from database BLOBs to Azure Blob Storage

**architecture.copilotmd**
- Visual architecture diagram (Mermaid format)
- Component descriptions
- Data flow documentation
- Security architecture
- Monitoring and observability setup

**progress.copilotmd**
- Real-time progress tracking
- Task completion status
- Issues and resolutions log
- Deployment attempt history

### Infrastructure Files (To Be Generated)

When executing the deployment plan, the following files will be created:

**azure.yaml**
- Azure Developer CLI (azd) configuration
- Service definitions
- Docker configuration references

**infra/main.bicep**
- Main Bicep infrastructure template
- All Azure resource definitions
- Resource dependencies and relationships

**infra/main.parameters.json**
- Parameter values for Bicep deployment
- Environment-specific configuration

**infra/resources.bicep** (optional)
- Module files for individual resource types
- Reusable infrastructure components

### Generated During Deployment

**summary.copilotmd**
- Post-deployment summary
- Deployed resource details
- Application URLs and endpoints
- Configuration information
- Next steps and recommendations

## Quick Start

### Prerequisites

1. **Azure Account**: Active Azure subscription with appropriate permissions
2. **Azure CLI**: Install from https://docs.microsoft.com/cli/azure/install-azure-cli
3. **Azure Developer CLI**: Install from https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd
4. **Docker**: For local testing (optional)

### Deployment Steps

1. **Review the Plan**
   ```bash
   # Read the deployment plan
   cat .azure/plan.copilotmd
   ```

2. **Login to Azure**
   ```bash
   az login
   azd auth login
   ```

3. **Initialize Environment**
   ```bash
   # Create new azd environment
   azd env new photoalbum-env
   
   # Set required variables
   azd env set AZURE_LOCATION eastus
   ```

4. **Deploy to Azure**
   ```bash
   # Preview deployment
   azd provision --preview
   
   # Deploy infrastructure and application
   azd up
   ```

5. **Verify Deployment**
   ```bash
   # Check application logs
   azd monitor
   
   # Get application URL
   azd env get-values | grep ENDPOINT
   ```

## Architecture Overview

### Current State (Local/Docker)
- Java Spring Boot 2.7.18 application
- Oracle Database 21c Express Edition
- Photos stored as database BLOBs
- Docker Compose deployment

### Target State (Azure)
- **Hosting**: Azure Container Apps (serverless)
- **Database**: Azure Database for PostgreSQL Flexible Server
- **Storage**: Azure Blob Storage for photos
- **Monitoring**: Application Insights
- **Security**: Managed Identity + Key Vault

### Key Changes

1. **Database Migration**: Oracle → PostgreSQL
   - Update JDBC driver dependency
   - Change Hibernate dialect
   - Minimal schema changes (Hibernate auto-generates)

2. **Storage Migration**: Database BLOBs → Azure Blob Storage
   - Add Azure Storage SDK
   - Implement PhotoStorageService
   - Update upload/retrieval logic

3. **Configuration**: Environment-based config
   - Connection strings from Key Vault
   - Managed Identity for Azure services
   - No hardcoded credentials

## Migration Phases

### Phase 1: Planning ✅
- Repository analysis
- Architecture design
- Resource selection
- Documentation creation

### Phase 2: Infrastructure Setup
- Generate Bicep templates
- Configure azd environment
- Provision Azure resources

### Phase 3: Code Changes
- Update dependencies
- Implement Azure Storage integration
- Update configuration for PostgreSQL
- Test locally (optional)

### Phase 4: Deployment
- Build and push Docker image
- Deploy to Container Apps
- Validate functionality

### Phase 5: Post-Deployment
- Configure monitoring
- Set up alerts
- Performance testing
- Documentation updates

## Azure Resources

### Compute
- **Azure Container Apps Environment**: Hosting platform
- **Container App (photoalbum-app)**: Application container

### Data & Storage
- **Azure Database for PostgreSQL**: Relational database
- **Azure Storage Account**: Photo blob storage

### Infrastructure Services
- **Azure Container Registry**: Docker image repository
- **Azure Key Vault**: Secrets management
- **Application Insights**: Monitoring and telemetry
- **Log Analytics Workspace**: Centralized logging

### Identity & Security
- **User-Assigned Managed Identity**: Secure authentication
- **Role Assignments**: Least privilege access

## Environment Variables

The application requires the following environment variables in Azure:

```bash
# Database Configuration
SPRING_DATASOURCE_URL=jdbc:postgresql://[server].postgres.database.azure.com:5432/photoalbum
SPRING_DATASOURCE_USERNAME=photoalbumadmin
SPRING_DATASOURCE_PASSWORD=[from-keyvault]

# Storage Configuration
AZURE_STORAGE_ACCOUNT_NAME=[storage-account-name]
AZURE_STORAGE_ACCOUNT_KEY=[from-keyvault]
AZURE_STORAGE_CONTAINER_NAME=photos

# Application Insights
APPLICATIONINSIGHTS_CONNECTION_STRING=[from-app-insights]

# Database Dialect
SPRING_JPA_DATABASE_PLATFORM=org.hibernate.dialect.PostgreSQLDialect
```

## Cost Estimation

### Development Environment (Monthly)
- Container Apps (Consumption): ~$5-20
- PostgreSQL (Burstable B1ms): ~$12
- Storage Account (Standard LRS): ~$1-5
- Container Registry (Basic): ~$5
- Application Insights: Free tier eligible
- **Total**: ~$25-45/month

### Production Environment (Monthly)
- Container Apps (with scaling): ~$50-200
- PostgreSQL (General Purpose): ~$100-300
- Storage Account with egress: ~$10-50
- Container Registry (Standard): ~$20
- Application Insights: ~$5-50
- **Total**: ~$185-620/month

*Note: Costs vary based on usage, region, and scaling requirements*

## Troubleshooting

### Common Issues

**Issue**: Deployment fails with region availability error
- **Solution**: Use `appmod-get-available-region-sku` to find available regions
- **Solution**: Update AZURE_LOCATION environment variable

**Issue**: Container fails to pull image
- **Solution**: Verify Managed Identity has AcrPull role
- **Solution**: Check Container Registry permissions

**Issue**: Database connection fails
- **Solution**: Verify firewall rules allow Azure services
- **Solution**: Check connection string in Key Vault
- **Solution**: Ensure PostgreSQL admin password is set correctly

**Issue**: Application can't access blob storage
- **Solution**: Verify storage account key in Key Vault
- **Solution**: Check Managed Identity permissions
- **Solution**: Ensure container name matches configuration

### Logging and Diagnostics

```bash
# View application logs
azd monitor

# Check container app logs
az containerapp logs show --name photoalbum-app --resource-group photoalbum-rg

# Check PostgreSQL logs
az postgres flexible-server server-logs list --resource-group photoalbum-rg --server-name [server-name]

# View Application Insights
# Navigate to Azure Portal → Application Insights → photoalbum-insights
```

## Security Best Practices

1. **Never commit secrets**: Use Key Vault and environment variables
2. **Use Managed Identity**: Avoid storing credentials
3. **Enable HTTPS only**: Force secure connections
4. **Regular updates**: Keep dependencies current
5. **Monitor security**: Enable Azure Defender for Cloud
6. **Backup regularly**: Configure database backup retention
7. **Network isolation**: Use private endpoints for production

## Next Steps After Deployment

1. **Configure Custom Domain** (Optional)
   - Add custom domain to Container App
   - Configure SSL/TLS certificate
   - Update DNS records

2. **Set Up CI/CD**
   - Create GitHub Actions workflow
   - Automate build and deployment
   - Add automated testing

3. **Performance Optimization**
   - Enable CDN for blob storage
   - Configure caching policies
   - Optimize container image size

4. **Disaster Recovery**
   - Configure geo-replication for storage
   - Set up database replica in another region
   - Test backup and restore procedures

5. **Monitoring and Alerts**
   - Create custom dashboards
   - Configure alert rules
   - Set up notification channels

## Additional Resources

- [Azure Container Apps Documentation](https://learn.microsoft.com/azure/container-apps/)
- [Azure Database for PostgreSQL Documentation](https://learn.microsoft.com/azure/postgresql/)
- [Azure Blob Storage Documentation](https://learn.microsoft.com/azure/storage/blobs/)
- [Azure Developer CLI Documentation](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
- [Spring Boot on Azure](https://learn.microsoft.com/azure/developer/java/spring-framework/)

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review Azure service health status
3. Check Application Insights for errors
4. Review deployment logs in Azure Portal
5. Consult Azure documentation

## License

This project follows the same license as the main PhotoAlbum-Java repository.
