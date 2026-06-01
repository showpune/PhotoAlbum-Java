# Modernization Plan: PhotoAlbum-Java – Migrate to Azure Database for PostgreSQL

**Project**: PhotoAlbum-Java

---

## Technical Framework

- **Language**: Java 8
- **Framework**: Spring Boot 2.7.18
- **Build Tool**: Maven
- **Database**: Oracle DB (ojdbc8)
- **Key Dependencies**: Spring Data JPA, Spring Boot Thymeleaf, Spring Boot Validation

---

## Overview

This migration moves the PhotoAlbum-Java application from Oracle DB to Azure Database for PostgreSQL with Managed Identity authentication. The application currently uses Oracle DB with password-based authentication. The new architecture will:

- Upgrade to Spring Boot 3.x and Java 17 as required by the Acme Corp Modernization Playbook (Java 8 and Spring Boot 2.x are prohibited per the playbook's hard boundaries)
- Replace Oracle DB with Azure Database for PostgreSQL, removing Oracle-specific SQL and JDBC dependencies
- Use Managed Identity for secure, credential-free authentication to Azure Database for PostgreSQL, eliminating hardcoded credentials

The migration follows a phased approach: upgrading the runtime first, then migrating the database engine, and finally securing connectivity with Managed Identity.

---

## Migration Impact Summary

| Application     | Original Service | New Azure Service             | Authentication   | Comments                                    |
|-----------------|------------------|-------------------------------|------------------|---------------------------------------------|
| PhotoAlbum-Java | Oracle DB        | Azure Database for PostgreSQL | Managed Identity | Migrate from Oracle to Azure PostgreSQL |

---

## Modernization Tasks

### Task 1: Upgrade to Spring Boot 3.x and Java 17

Upgrade the application from Spring Boot 2.7.18 and Java 8 to Spring Boot 3.x and Java 17. This is a mandatory prerequisite per the Acme Corp Modernization Playbook, which prohibits Java 8 and Spring Boot 2.x. The upgrade also includes migrating `javax.*` namespaces to `jakarta.*`.

### Task 2: Migrate Oracle DB to PostgreSQL

Migrate the application's data layer from Oracle DB to PostgreSQL. This includes replacing the Oracle JDBC driver (`ojdbc8`) with the PostgreSQL JDBC driver, updating JPA/Hibernate dialect configuration, and migrating any Oracle-specific SQL syntax or sequences to PostgreSQL-compatible equivalents.

### Task 3: Configure Managed Identity for Azure Database for PostgreSQL

Replace password-based database authentication with Azure Managed Identity for connecting to Azure Database for PostgreSQL. Remove hardcoded credentials from application configuration and configure the application to obtain access tokens using Managed Identity, in compliance with the Acme Corp policy that requires Managed Identity for all service-to-service authentication.
