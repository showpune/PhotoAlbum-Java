# Modernization Plan: Migrate PhotoAlbum to Azure

**Project**: PhotoAlbum

---

## Technical Framework

- **Language**: Java 8 (target: Java 17 via Spring Boot 3.x upgrade)
- **Framework**: Spring Boot 2.7.18 (target: Spring Boot 3.x)
- **Build Tool**: Maven 3.9
- **Database**: Oracle DB (BLOB storage for photos; target: Azure Database for PostgreSQL)
- **Key Dependencies**: Spring Data JPA, Hibernate, Spring MVC (Thymeleaf), Commons IO

---

## Overview

This migration modernizes the PhotoAlbum Spring Boot application to run on Azure. The application currently runs on Java 8 with Spring Boot 2.7.18 and uses Oracle DB to store photo metadata and binary image data as BLOBs. The new architecture will:

- Upgrade the runtime to Java 17+ and Spring Boot 3.x, enabling Jakarta EE compatibility and long-term support
- Migrate the Oracle database to PostgreSQL as an intermediate step toward cloud-native storage
- Connect to Azure Database for PostgreSQL with Managed Identity for secure, credential-free authentication

The migration follows a phased approach: framework upgrade first, then database migration, and finally Azure cloud integration.

---

## Migration Impact Summary

| Application  | Original Service  | New Azure Service                    | Authentication    | Comments                                 |
|--------------|-------------------|--------------------------------------|-------------------|------------------------------------------|
| PhotoAlbum   | Java 8 / Spring Boot 2.7.18 | Java 17+ / Spring Boot 3.x | N/A               | Includes javax.* → jakarta.* migration  |
| PhotoAlbum   | Oracle DB         | PostgreSQL                           | JDBC credentials  | BLOB photo data migrated to bytea        |
| PhotoAlbum   | PostgreSQL (local) | Azure Database for PostgreSQL        | Managed Identity  | Credential-free authentication via MI   |

---

## Task List

| # | Task | Type | Skill |
|---|------|------|-------|
| 1 | Upgrade Spring Boot to 3.x | upgrade | execute-upgrade-task |
| 2 | Migrate Oracle DB to PostgreSQL | transform | migration-oracle-to-postgresql |
| 3 | Migrate PostgreSQL to Azure Database for PostgreSQL with Managed Identity | transform | migration-mi-postgresql-azure-sdk-public-cloud |

---

## Notes

- Java 8 is below the minimum required version (17) for Spring Boot 3.x; the upgrade task is mandatory and must run first.
- The Spring Boot 3.x upgrade encompasses JDK 17, Spring Framework 6.x, and the migration from `javax.*` to `jakarta.*` namespaces.
- Photo binary data is currently stored as Oracle BLOBs; after migration this will be stored as PostgreSQL `bytea`.
- No explicit deployment or containerization was requested; those tasks are excluded from this plan.
