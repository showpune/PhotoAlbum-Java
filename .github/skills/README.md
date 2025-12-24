# Skills Directory

This directory contains AppMod Kit skills for the PhotoAlbum-Java modernization project.

## Available Skills

### 1. Create Modernization Plan
**Path**: `create-modernization-plan/SKILL.md`

**Purpose**: Generates a comprehensive migration plan for moving the PhotoAlbum-Java application from Oracle Database and Docker deployment to Azure cloud services.

**What it does**:
- Analyzes current architecture (Spring Boot + Oracle + Docker)
- Recommends Azure target architecture (App Service + PostgreSQL + Blob Storage)
- Creates detailed migration plan with 6 phases:
  1. Infrastructure Setup
  2. Code Modifications
  3. Database Migration
  4. CI/CD Pipeline
  5. Testing Strategy
  6. Cutover Plan
- Provides cost estimates and security recommendations
- Includes sample code and Infrastructure as Code templates

**How to use**:
1. Review the skill documentation: `create-modernization-plan/SKILL.md`
2. Check the generated migration plan: `../.github/AZURE_MIGRATION_PLAN.md`
3. Follow the phased approach outlined in the migration plan
4. Use the provided code examples and Bicep templates

## Project Context

**Current State**:
- Java Spring Boot 2.7.18 application
- Oracle Database 21c (with BLOB storage for photos)
- Docker Compose deployment
- Local/on-premises hosting

**Target State**:
- Azure App Service (Linux, Java 11)
- Azure Database for PostgreSQL
- Azure Blob Storage (for photos)
- CI/CD via GitHub Actions
- Full cloud-native architecture

## Documentation

- **Main Migration Plan**: `../.github/AZURE_MIGRATION_PLAN.md`
- **AppMod Configuration**: `../.github/APPMOD_CONFIG.md`
- **Project README**: `../../README.md`

## Next Steps

1. Review the migration plan in detail
2. Set up Azure subscription and resource group
3. Create development branch for Azure migration
4. Begin Phase 1: Infrastructure Setup
5. Follow the migration phases sequentially

---

**Last Updated**: December 24, 2025
