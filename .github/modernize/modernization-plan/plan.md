# Modernization Plan: PostgreSQL Migration

**Project**: Photo Album

---

## Technical Framework

- **Language**: Java 8
- **Framework**: Spring Boot 2.7.18
- **Build Tool**: Maven
- **Database**: Oracle DB (ojdbc8, connected via `jdbc:oracle:thin:@oracle-db:1521/FREEPDB1`)
- **Key Dependencies**: Spring Data JPA, Hibernate, Spring Boot Web, Thymeleaf

---

## Overview

This migration moves the Photo Album application's data layer from Oracle DB to Azure Database for PostgreSQL, with secure credential-free authentication via Azure Managed Identity.

The application currently connects to an Oracle database using hardcoded credentials in `application.properties`. The new architecture will:

- Replace the Oracle JDBC driver and Oracle-specific SQL/Hibernate configuration with PostgreSQL equivalents
- Provision Azure Database for PostgreSQL as the managed cloud database service
- Eliminate hardcoded database credentials by adopting Azure Managed Identity for secure, password-free authentication

The migration follows a two-phase approach: first migrating the data layer from Oracle to open-source PostgreSQL, then upgrading the connection to Azure Database for PostgreSQL with Managed Identity.

---

## Migration Impact Summary

| Application   | Original Service | New Azure Service                   | Authentication   | Comments                          |
|---------------|------------------|-------------------------------------|------------------|-----------------------------------|
| Photo Album   | Oracle DB        | Azure Database for PostgreSQL       | Managed Identity | Migrate Oracle schema and queries |

---

## Migration Tasks

### Task 1 – Migrate Oracle DB to PostgreSQL

Migrate the application's data layer from Oracle DB to PostgreSQL. This includes replacing the Oracle JDBC driver with the PostgreSQL driver, updating the Hibernate dialect, converting any Oracle-specific SQL syntax and DDL to PostgreSQL-compatible equivalents, and updating `application.properties` with a PostgreSQL connection configuration.

**Skill**: `migration-oracle-to-postgresql`

---

### Task 2 – Migrate PostgreSQL to Azure Database for PostgreSQL with Managed Identity

Upgrade the PostgreSQL connection to target Azure Database for PostgreSQL and replace password-based authentication with Azure Managed Identity. This includes updating the Spring datasource configuration and adding the Azure Identity SDK to achieve secure, credential-free connectivity to the managed Azure database service.

**Skill**: `migration-mi-postgresql-azure-sdk-public-cloud`

**Depends on**: Task 1

---
