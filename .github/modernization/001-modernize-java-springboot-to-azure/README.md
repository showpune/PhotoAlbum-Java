# Modernization Plan - Java Spring Boot to Azure

This directory contains the modernization plan for migrating the Photo Album Java application to Azure.

## Quick Links

- **Modernization Plan**: [plan.md](./plan.md) - Detailed plan with tasks and execution notes
- **Issue Report**: [MODERNIZATION_ISSUE_REPORT.md](../../appmod/MODERNIZATION_ISSUE_REPORT.md) - Assessment report for GitHub issue creation
- **Assessment Results**: [summary.md](../../appmod/appcat/result/summary.md) - Full AppCAT assessment results

## How to Create a GitHub Issue

To track this modernization work, create a GitHub issue with the following steps:

1. Go to your repository: https://github.com/showpune/PhotoAlbum-Java
2. Click on "Issues" tab
3. Click "New Issue"
4. Copy the content from `.github/appmod/MODERNIZATION_ISSUE_REPORT.md`
5. Paste it as the issue body
6. Title: "Java Application Modernization - Azure Migration Assessment"
7. Add labels: `enhancement`, `modernization`, `azure`
8. Click "Submit new issue"

## Modernization Overview

### Current State
- **Java**: 8
- **Spring Boot**: 2.7.18
- **Database**: Oracle 21c Express Edition
- **Issues**: 3 mandatory, 10 potential, 1 optional

### Target State
- **Java**: 17
- **Spring Boot**: 3.x
- **Database**: Azure Database for PostgreSQL
- **Security**: Azure Key Vault for secrets management

### Tasks (3 Total)

1. **Upgrade Spring Boot to 3.x** (includes JDK 8→17, Spring Framework→6.x, javax→jakarta)
   - Solution ID: `spring-boot-upgrade`

2. **Migrate from Oracle to Azure PostgreSQL**
   - Solution ID: `oracle-to-postgresql`

3. **Migrate credentials to Azure Key Vault**
   - Solution ID: `plaintext-credential-to-azure-keyvault`

## Next Steps

### Option 1: Review and Execute Plan
```bash
# Review the plan
cat .github/modernization/001-modernize-java-springboot-to-azure/plan.md

# When ready, execute the plan (if you have the appmod-kit tools)
# /appmod-kit.run-plan
```

### Option 2: Manual Execution
1. Review the plan in `plan.md`
2. Execute each task in order
3. Test after each task completion
4. Update the GitHub issue with progress

## Important Notes

- **Task Order**: Tasks must be executed sequentially (upgrade first, then migrations)
- **Testing**: Build and test after each task
- **Rollback**: Each task should be committed separately for easy rollback
- **Security**: Task 3 (Key Vault) is critical before production deployment

## Support Resources

- [GitHub Copilot App Modernization](https://aka.ms/ghcp-appmod)
- [Spring Boot 3 Migration Guide](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-3.0-Migration-Guide)
- [Azure Database for PostgreSQL Documentation](https://learn.microsoft.com/azure/postgresql/)
- [Azure Key Vault for Spring Boot](https://learn.microsoft.com/azure/developer/java/spring-framework/configure-spring-boot-starter-java-app-with-azure-key-vault)
