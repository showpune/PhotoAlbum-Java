# Azure Application Modernization Migration Plan
## Photo Album Java Application - Oracle to Azure Migration

### Executive Summary
This document outlines the comprehensive migration plan for the Photo Album Java application from a local Oracle Database deployment to Microsoft Azure cloud platform. The migration follows Azure App Modernization toolkit (appmod-kit) principles and best practices.

---

## 1. Current State Assessment

### Application Architecture
- **Application Type**: Spring Boot 2.7.18 Web Application
- **Programming Language**: Java 8
- **Web Framework**: Spring Boot with Thymeleaf templating
- **Build Tool**: Maven
- **Deployment**: Docker containerized application

### Technology Stack
- **Backend Framework**: Spring Boot 2.7.18
- **ORM**: Spring Data JPA with Hibernate
- **Database**: Oracle Database 21c Express Edition (currently)
- **Web Server**: Embedded Tomcat (Spring Boot)
- **Frontend**: Bootstrap 5.3.0, Vanilla JavaScript
- **Containerization**: Docker & Docker Compose

### Current Database Schema
```
PHOTOS Table (Oracle):
- ID (VARCHAR2(36), PK, UUID)
- ORIGINAL_FILE_NAME (VARCHAR2(255))
- STORED_FILE_NAME (VARCHAR2(255))
- FILE_PATH (VARCHAR2(500))
- FILE_SIZE (NUMBER)
- MIME_TYPE (VARCHAR2(50))
- UPLOADED_AT (TIMESTAMP)
- WIDTH (NUMBER)
- HEIGHT (NUMBER)
- PHOTO_DATA (BLOB)
```

### Key Features
- Photo upload with drag-and-drop
- Gallery view with responsive grid
- Photo detail view with metadata
- BLOB storage in database
- File validation (JPEG, PNG, GIF, WebP; max 10MB)
- Photo deletion capability

### Current Deployment Model
- Local Docker Compose deployment
- Oracle DB container + Application container
- No external file storage (all photos in DB BLOBs)

---

## 2. Migration Strategy

### Target Azure Architecture

#### Recommended Azure Services
1. **Compute**: Azure App Service (Web App for Containers)
   - Fully managed platform
   - Built-in auto-scaling
   - Easy integration with Azure services
   - Container support
   - Alternative: Azure Kubernetes Service (AKS) for more control

2. **Database**: Azure Database for PostgreSQL - Flexible Server
   - Managed PostgreSQL service
   - High availability options
   - Automatic backups
   - Compatibility with Spring Boot JPA
   - Cost-effective alternative to Oracle

3. **Storage**: Azure Blob Storage (Recommended architectural change)
   - Separate photo storage from database
   - Better performance and scalability
   - Cost-effective for large files
   - CDN integration possible
   - Alternative: Keep BLOB storage in PostgreSQL for minimal changes

4. **Container Registry**: Azure Container Registry (ACR)
   - Store application container images
   - Integrated with App Service and AKS

5. **Monitoring**: Azure Application Insights
   - Application performance monitoring
   - Log analytics
   - Distributed tracing

6. **CI/CD**: GitHub Actions
   - Automated build and deployment
   - Integration with Azure services

### Migration Approach
**Strategy**: Replatform (Lift and Optimize)
- Migrate with minimal code changes
- Replace Oracle with PostgreSQL
- Optimize for cloud-native features
- Consider architectural improvements (external blob storage)

---

## 3. Detailed Migration Plan

### Phase 1: Assessment and Planning (Current Phase)
**Duration**: 1-2 weeks

#### Tasks:
- [x] Document current architecture
- [x] Identify all dependencies
- [x] Analyze database schema compatibility
- [x] Review existing Azure setup scripts
- [x] Create migration plan document
- [ ] Identify required code changes
- [ ] Estimate migration effort and cost
- [ ] Define rollback strategy

#### Deliverables:
- This migration plan document
- Risk assessment document
- Cost estimation

### Phase 2: Database Migration Preparation
**Duration**: 1-2 weeks

#### Tasks:
- [ ] Set up Azure Database for PostgreSQL Flexible Server
- [ ] Create PostgreSQL database schema
- [ ] Update Hibernate dialect from OracleDialect to PostgreSQLDialect
- [ ] Test database compatibility locally
- [ ] Create data migration scripts (if migrating existing data)
- [ ] Update application.properties for PostgreSQL

#### Code Changes Required:
```properties
# From:
spring.datasource.driver-class-name=oracle.jdbc.OracleDriver
spring.jpa.database-platform=org.hibernate.dialect.OracleDialect

# To:
spring.datasource.driver-class-name=org.postgresql.Driver
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
```

#### pom.xml Changes:
```xml
<!-- Remove Oracle dependency -->
<!-- Add PostgreSQL dependency -->
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <scope>runtime</scope>
</dependency>
```

### Phase 3: Application Modernization
**Duration**: 2-3 weeks

#### Tasks:
- [ ] Update database driver and dependencies
- [ ] Refactor any Oracle-specific SQL or HQL
- [ ] Test application with PostgreSQL locally
- [ ] (Optional) Implement Azure Blob Storage for photos
- [ ] Add Azure Application Insights SDK
- [ ] Configure application for Azure environment
- [ ] Update Dockerfile for Azure deployment
- [ ] Create Kubernetes manifests or App Service configuration

#### Optional Enhancement: Azure Blob Storage Integration
If implementing external blob storage:
- [ ] Add Azure Storage SDK dependency
- [ ] Create Azure Storage Account
- [ ] Update Photo entity to store blob URL instead of data
- [ ] Implement blob upload/download service
- [ ] Update PhotoService implementation
- [ ] Test end-to-end with Azure Blob Storage

### Phase 4: Azure Infrastructure Setup
**Duration**: 1 week

#### Tasks:
- [ ] Create Azure Resource Group
- [ ] Provision Azure Container Registry (ACR)
- [ ] Set up Azure App Service or AKS cluster
- [ ] Configure Azure Database for PostgreSQL
- [ ] Set up Azure Blob Storage (if using)
- [ ] Configure networking and security
- [ ] Set up Azure Key Vault for secrets
- [ ] Configure Application Insights

#### Existing Scripts:
- Review and update `azure-setup.ps1` (already exists)
- The script already provisions:
  - Resource Group
  - Azure Container Registry
  - Azure Kubernetes Service
  - PostgreSQL Flexible Server
  - Database user and permissions

### Phase 5: CI/CD Pipeline Setup
**Duration**: 1 week

#### Tasks:
- [ ] Create GitHub Actions workflow for build
- [ ] Configure Docker image build and push to ACR
- [ ] Set up deployment workflow to Azure
- [ ] Configure environment variables and secrets
- [ ] Implement staging and production environments
- [ ] Add automated testing in pipeline
- [ ] Configure deployment gates and approvals

### Phase 6: Testing and Validation
**Duration**: 2 weeks

#### Tasks:
- [ ] Deploy application to Azure staging environment
- [ ] Perform functional testing
- [ ] Perform performance testing
- [ ] Validate database connectivity
- [ ] Test photo upload/download functionality
- [ ] Verify monitoring and logging
- [ ] Load testing with expected traffic
- [ ] Security testing and vulnerability scanning
- [ ] Create runbook for operations

### Phase 7: Production Deployment
**Duration**: 1 week

#### Tasks:
- [ ] Prepare production deployment plan
- [ ] Schedule maintenance window
- [ ] Execute production deployment
- [ ] Migrate production data (if applicable)
- [ ] Smoke test critical paths
- [ ] Monitor application performance
- [ ] Document lessons learned

### Phase 8: Post-Migration
**Duration**: Ongoing

#### Tasks:
- [ ] Monitor application health and performance
- [ ] Optimize costs
- [ ] Address any issues or bugs
- [ ] Train team on Azure operations
- [ ] Document operational procedures
- [ ] Plan for continuous improvements

---

## 4. Technical Requirements

### Prerequisites
- Azure subscription with necessary permissions
- GitHub repository access
- Docker Desktop for local testing
- Azure CLI installed
- kubectl installed (if using AKS)
- Maven 3.x
- Java 8 JDK

### Dependencies to Add/Update
```xml
<!-- Add PostgreSQL driver -->
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <scope>runtime</scope>
</dependency>

<!-- Optional: Azure Storage SDK for Blob Storage -->
<dependency>
    <groupId>com.azure</groupId>
    <artifactId>azure-storage-blob</artifactId>
    <version>12.25.0</version>
</dependency>

<!-- Optional: Azure Application Insights -->
<dependency>
    <groupId>com.microsoft.azure</groupId>
    <artifactId>applicationinsights-spring-boot-starter</artifactId>
    <version>2.6.4</version>
</dependency>
```

### Configuration Files to Update
1. **application.properties** - Database connection strings
2. **application-azure.properties** - Azure-specific configuration (new)
3. **pom.xml** - Dependencies
4. **Dockerfile** - Azure-optimized build
5. **docker-compose.yml** - Local PostgreSQL testing
6. **.github/workflows/** - CI/CD pipelines (new)

---

## 5. Database Migration Details

### Schema Compatibility Analysis

#### Data Type Mappings
| Oracle Type | PostgreSQL Type | Notes |
|-------------|----------------|-------|
| VARCHAR2(n) | VARCHAR(n) | Direct mapping |
| NUMBER | NUMERIC/INTEGER | Context dependent |
| BLOB | BYTEA | Direct mapping |
| TIMESTAMP | TIMESTAMP | Direct mapping |

#### Identified Compatibility Issues
1. **Default timestamp**: Oracle uses `SYSTIMESTAMP`, PostgreSQL uses `CURRENT_TIMESTAMP`
   - Hibernate will handle this automatically

2. **Sequence generation**: 
   - Oracle uses sequence objects
   - PostgreSQL uses SERIAL or SEQUENCE
   - Hibernate's UUID generation strategy is database-agnostic ✓

3. **BLOB handling**:
   - Oracle: BLOB type
   - PostgreSQL: BYTEA type
   - Hibernate will map automatically with @Lob annotation ✓

### Migration Options

#### Option A: Keep Database BLOB Storage (Minimal Change)
**Pros**:
- Minimal code changes
- Faster migration
- ACID compliance maintained

**Cons**:
- Database size increases significantly
- Performance limitations at scale
- Higher database costs

#### Option B: Migrate to Azure Blob Storage (Recommended)
**Pros**:
- Better scalability
- Cost-effective for large files
- Better performance
- CDN integration possible
- Separate concerns

**Cons**:
- More code changes required
- Additional service to manage
- Requires refactoring PhotoService

---

## 6. Security Considerations

### Security Measures
1. **Database Security**:
   - Use Azure Key Vault for connection strings
   - Enable SSL/TLS for database connections
   - Configure firewall rules (Azure services only)
   - Enable Microsoft Entra ID authentication (optional)

2. **Application Security**:
   - Use managed identities for Azure service access
   - Store secrets in Azure Key Vault
   - Enable HTTPS only
   - Implement proper CORS policies
   - Regular security scanning with Azure Security Center

3. **Network Security**:
   - Use Virtual Network integration
   - Configure NSG rules
   - Enable private endpoints for services
   - Implement Azure Front Door or Application Gateway

4. **Data Security**:
   - Enable encryption at rest (automatic in Azure)
   - Enable encryption in transit
   - Regular backups (automatic)
   - Implement retention policies

---

## 7. Cost Estimation

### Monthly Cost Estimate (USD)
Based on Azure pricing for West US 3 region:

| Service | SKU/Size | Estimated Cost |
|---------|----------|----------------|
| Azure App Service | P1v3 (Production) | ~$100 |
| Azure Database for PostgreSQL | Standard_D4ads_v5 | ~$250 |
| Azure Container Registry | Basic | ~$5 |
| Azure Blob Storage | Standard LRS (if used) | ~$20 |
| Application Insights | Basic | ~$10 |
| Azure Key Vault | Standard | ~$1 |
| **Total Monthly Estimate** | | **~$386** |

*Note: Costs may vary based on usage, region, and reserved capacity options*

### Cost Optimization Strategies
1. Use reserved capacity for predictable workloads (up to 60% savings)
2. Scale down non-production environments
3. Use Azure Hybrid Benefit (if applicable)
4. Implement auto-scaling to match demand
5. Use lifecycle management for Blob Storage
6. Monitor and optimize database DTU usage

---

## 8. Risk Assessment and Mitigation

### High-Priority Risks

#### Risk 1: Data Loss During Migration
**Mitigation**:
- Comprehensive backup before migration
- Test migration on staging environment first
- Implement rollback procedures
- Validate data integrity post-migration

#### Risk 2: Performance Degradation
**Mitigation**:
- Performance testing before go-live
- Set up Application Insights monitoring
- Implement caching strategies
- Optimize database queries
- Load testing with expected traffic patterns

#### Risk 3: Extended Downtime
**Mitigation**:
- Blue-green deployment strategy
- Prepare rollback plan
- Schedule migration during low-traffic period
- Have support team on standby

#### Risk 4: Database Compatibility Issues
**Mitigation**:
- Test all database operations thoroughly
- Review and update any native SQL queries
- Test with PostgreSQL locally before Azure deployment
- Keep Oracle database available for rollback

---

## 9. Testing Strategy

### Testing Phases

#### 1. Unit Testing
- Test data access layer with PostgreSQL
- Test business logic components
- Maintain existing test coverage

#### 2. Integration Testing
- Test database integration
- Test Azure service integration
- Test photo upload/download flows
- Test authentication and authorization

#### 3. System Testing
- End-to-end testing of all features
- Test in Azure staging environment
- Verify all user workflows

#### 4. Performance Testing
- Load testing with concurrent users
- Database query performance
- Photo upload/download performance
- Response time benchmarks

#### 5. Security Testing
- Vulnerability scanning
- Penetration testing
- Security best practices validation
- OWASP Top 10 validation

---

## 10. Rollback Plan

### Rollback Triggers
- Critical functionality broken
- Data corruption detected
- Performance unacceptable
- Security vulnerability discovered

### Rollback Procedures
1. Stop Azure deployment
2. Redirect traffic to previous environment
3. Restore database from backup (if needed)
4. Investigate and fix issues
5. Re-test before retry

### Rollback Success Criteria
- Application fully functional
- No data loss
- All users can access system
- Performance meets SLA

---

## 11. Success Criteria

### Technical Success Criteria
- ✅ Application deployed and running in Azure
- ✅ All features working as expected
- ✅ Database migration completed successfully
- ✅ No data loss or corruption
- ✅ Performance meets or exceeds current baseline
- ✅ Monitoring and alerting operational
- ✅ CI/CD pipeline functional

### Business Success Criteria
- ✅ Zero unplanned downtime
- ✅ User satisfaction maintained
- ✅ Cost within budget
- ✅ Scalability improved
- ✅ Operational efficiency improved

---

## 12. Timeline Summary

| Phase | Duration | Dependencies |
|-------|----------|--------------|
| Assessment and Planning | 1-2 weeks | None |
| Database Migration Prep | 1-2 weeks | Planning complete |
| Application Modernization | 2-3 weeks | Database prep |
| Azure Infrastructure Setup | 1 week | Can be parallel |
| CI/CD Pipeline Setup | 1 week | Infrastructure ready |
| Testing and Validation | 2 weeks | All dev complete |
| Production Deployment | 1 week | Testing passed |
| Post-Migration Monitoring | Ongoing | Deployment complete |

**Total Estimated Duration**: 9-12 weeks

---

## 13. Key Contacts and Responsibilities

### Migration Team Roles
- **Migration Lead**: Overall coordination and decision-making
- **Database Architect**: Database migration and optimization
- **DevOps Engineer**: Azure infrastructure and CI/CD
- **Application Developer**: Code changes and testing
- **QA Engineer**: Testing and validation
- **Security Engineer**: Security review and compliance

---

## 14. Documentation Requirements

### Documentation to Create/Update
- [ ] Azure architecture diagrams
- [ ] Deployment runbooks
- [ ] Operational procedures
- [ ] Troubleshooting guides
- [ ] Backup and recovery procedures
- [ ] Disaster recovery plan
- [ ] API documentation (if applicable)
- [ ] User guides (if UI changes)

---

## 15. Next Steps

### Immediate Actions
1. ✅ Review and approve this migration plan
2. ✅ Assign team members to roles
3. ✅ Set up project tracking (Azure DevOps or GitHub Projects)
4. ⏳ Begin Phase 2: Database Migration Preparation
5. ⏳ Set up Azure subscription and resources

### Week 1 Tasks
- [ ] Create Azure subscription (if not exists)
- [ ] Set up development environment
- [ ] Install PostgreSQL locally for testing
- [ ] Update pom.xml with PostgreSQL dependency
- [ ] Test application with PostgreSQL locally
- [ ] Review existing azure-setup.ps1 script
- [ ] Create GitHub Actions workflows

---

## Appendix A: Useful Commands

### Azure CLI Commands
```bash
# Login to Azure
az login

# Set subscription
az account set --subscription <subscription-id>

# Run setup script
./azure-setup.ps1

# Get AKS credentials (if using AKS)
az aks get-credentials --resource-group <rg-name> --name <cluster-name>

# List all resources in resource group
az resource list --resource-group <rg-name> --output table
```

### Local Testing Commands
```bash
# Run with PostgreSQL locally
docker run --name postgres -e POSTGRES_PASSWORD=photoalbum -e POSTGRES_USER=photoalbum -e POSTGRES_DB=photoalbum -p 5432:5432 -d postgres:15

# Build application
mvn clean package

# Run application
mvn spring-boot:run

# Run tests
mvn test

# Build Docker image
docker build -t photo-album:latest .
```

---

## Appendix B: Reference Links

### Azure Documentation
- [Azure App Service](https://docs.microsoft.com/en-us/azure/app-service/)
- [Azure Database for PostgreSQL](https://docs.microsoft.com/en-us/azure/postgresql/)
- [Azure Blob Storage](https://docs.microsoft.com/en-us/azure/storage/blobs/)
- [Azure Container Registry](https://docs.microsoft.com/en-us/azure/container-registry/)
- [Azure Application Insights](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)

### Migration Resources
- [Azure Migrate Application and Code Assessment for Java](https://learn.microsoft.com/en-us/azure/migrate/appcat/java)
- [Java on Azure Migration Guide](https://docs.microsoft.com/en-us/azure/developer/java/migration/)
- [Spring Boot on Azure](https://docs.microsoft.com/en-us/azure/developer/java/spring/)

### Tools
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/)
- [Maven Azure Plugins](https://github.com/microsoft/azure-maven-plugins)

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-12-22 | Migration Team | Initial migration plan created |

---

**Plan Status**: ✅ Draft Complete - Ready for Review
**Next Review Date**: TBD
**Plan Owner**: Migration Lead
