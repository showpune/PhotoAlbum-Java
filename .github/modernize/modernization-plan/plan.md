# Modernization Plan: PhotoAlbum-Java Azure Modernization

**Project**: PhotoAlbum-Java

---

## Technical Framework

- **Language**: Java 8
- **Framework**: Spring Boot 2.7.18
- **Build Tool**: Maven 3
- **Database**: Oracle (JDBC, Spring Data JPA with OracleDialect, BLOB storage)
- **Key Dependencies**: Spring Data JPA, Spring MVC (Thymeleaf), commons-io,
  SLF4J (LoggerFactory)

---

## Overview

> This migration modernizes the PhotoAlbum-Java application to comply with the
> Acme Corp Modernization Playbook. The application currently runs on Java 8 /
> Spring Boot 2.7.18, connects to Oracle with hardcoded credentials, and uses
> SLF4J for logging and exception-based error-handling flows. The new
> architecture will:
>
> - Upgrade the runtime to Java 17 and Spring Boot 3.x, eliminating end-of-life
>   dependencies and enabling Jakarta EE APIs
> - Replace Oracle Database with Azure Database for PostgreSQL, reducing
>   operational overhead and aligning with approved Azure data services
> - Move all sensitive credentials from application.properties into Azure Key
>   Vault accessed via Managed Identity, satisfying the SOC 2 secrets-management
>   control
> - Replace SLF4J logging with the internal InternalLogger library to ensure
>   consistent trace-context propagation and structured JSON output
> - Replace exception-based error-handling flows with the Result\<T\> pattern
>   per the P0-2024-0847 post-incident mandate
>
> The migration follows a phased approach: runtime upgrade first, then data
> and secrets migration, then observability and error-handling conformance.

---

## Migration Impact Summary

| Application      | Original Service      | New Azure Service               | Authentication    | Comments                              |
|------------------|-----------------------|---------------------------------|-------------------|---------------------------------------|
| PhotoAlbum-Java  | Java 8 / Spring Boot 2.7.18 | Java 17 / Spring Boot 3.x | N/A           | Playbook mandates upgrade from EoL versions |
| PhotoAlbum-Java  | Oracle Database       | Azure Database for PostgreSQL   | Managed Identity  | Oracle is not an approved Azure service |
| PhotoAlbum-Java  | Hardcoded DB creds    | Azure Key Vault                 | Managed Identity  | Policy prohibits plaintext credentials |
| PhotoAlbum-Java  | SLF4J (LoggerFactory) | InternalLogger (com.acme.logging.InternalLogger) | N/A | Policy prohibits SLF4J |
| PhotoAlbum-Java  | Exception-based flow  | Result\<T\> (com.acme.commons.Result) | N/A        | P0-2024-0847 mandate                  |

---

## Migration Tasks

### Task 1 — Spring Boot 3.x Upgrade (Java 17)

Upgrade the application from Java 8 / Spring Boot 2.7.18 to Java 17 /
Spring Boot 3.x (latest stable). This includes the migration of all
`javax.*` imports to `jakarta.*` and any other breaking-change remediation
required by the new major version.

**Why**: Java 8 and 11 are end-of-life for internal use. Spring Boot 2.x
applications must be upgraded per the Acme Corp playbook. Spring Boot 3.x
requires a minimum of Java 17.

---

### Task 2 — Oracle DB to Azure Database for PostgreSQL

Migrate the application's data layer from Oracle Database (JDBC /
OracleDialect / ojdbc8) to Azure Database for PostgreSQL with Managed
Identity authentication.

**Why**: Oracle is not an approved Azure target data service. Azure
Database for PostgreSQL is the approved alternative. Managed Identity
removes the need for hardcoded connection credentials.

---

### Task 3 — Plaintext Credentials to Azure Key Vault

Migrate all sensitive values (database credentials, connection strings)
that are currently stored in `application.properties` to Azure Key Vault,
accessed via Managed Identity.

**Why**: Hardcoded credentials in configuration files are prohibited by
policy. Azure Key Vault with Managed Identity is the mandated alternative.

---

### Task 4 — Logging Migration to InternalLogger

Replace all SLF4J (`org.slf4j.Logger` / `LoggerFactory`) usages with the
internal `com.acme.logging.InternalLogger` throughout the application
(controllers, services, utilities).

**Why**: SLF4J does not integrate with the internal trace-context
propagation system. All applications must use InternalLogger for structured
JSON output with team ownership and environment tags.

---

### Task 5 — Error Handling Migration to Result\<T\>

Replace exception-based flow control (throw/catch used for business logic,
`@ControllerAdvice` for business exceptions) with the
`com.acme.commons.Result<T>` pattern. Return `Result.success()` or
`Result.failure()` from service methods instead of throwing exceptions.

**Why**: Exception-based business-logic flow control is prohibited per the
P0-2024-0847 post-incident mandate. The Result\<T\> pattern is the approved
alternative for explicit error handling.

---
