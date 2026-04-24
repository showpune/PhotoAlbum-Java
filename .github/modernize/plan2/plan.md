# Modernization Plan: Migrate Oracle Database to Azure PostgreSQL with Managed Identity

**Project**: Photo Album

---

## Technical Framework

- **Language**: Java 8 (1.8)
- **Framework**: Spring Boot 2.7.18
- **Build Tool**: Maven 3.9.6
- **Database**: Oracle Database (21c Express / Oracle Free 23ai)
- **Key Dependencies**: Spring Data JPA, Hibernate (OracleDialect), ojdbc8 (Oracle JDBC driver)

---

## Overview

> This migration moves the Photo Album application from Oracle Database to Azure Database for PostgreSQL Flexible Server with Managed Identity authentication. The application currently uses Oracle-specific SQL syntax (ROWNUM pagination, TO_CHAR date functions, NVL null handling, analytical window functions), Oracle JDBC driver, and Hibernate OracleDialect. The new architecture will:
>
> - Replace Oracle-specific SQL constructs with PostgreSQL-compatible equivalents for portable, standards-based database access
> - Swap the Oracle JDBC driver for the PostgreSQL JDBC driver and update Hibernate dialect
> - Enable passwordless Managed Identity authentication to Azure Database for PostgreSQL Flexible Server, eliminating hardcoded credentials
>
> The migration is executed in two sequential phases: first converting Oracle-specific code to standard PostgreSQL, then integrating Azure SDK Managed Identity for secure, credential-free connectivity.

---

## Migration Impact Summary

| Application   | Original Service     | New Azure Service                        | Authentication   | Comments                                           |
|---------------|----------------------|------------------------------------------|------------------|----------------------------------------------------|
| Photo Album   | Oracle Database      | Azure Database for PostgreSQL Flexible   | Managed Identity | Replace Oracle SQL, dialect, and JDBC driver       |

---

## Tasks

| # | Task | Type | Skill |
|---|------|------|-------|
| 1 | Migrate Oracle DB code to PostgreSQL | transform | migration-oracle-to-postgresql |
| 2 | Migrate to Azure PostgreSQL with Managed Identity | transform | migration-mi-postgresql-azure-sdk-public-cloud |
