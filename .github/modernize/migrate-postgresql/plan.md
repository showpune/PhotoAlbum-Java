# Modernization Plan: Migrate PostgreSQL

**Project**: Photo Album

---

## Technical Framework

- **Language**: Java 8
- **Framework**: Spring Boot 2.7.18
- **Build Tool**: Maven
- **Database**: Oracle Database (ojdbc8, OracleDialect)
- **Key Dependencies**: Spring Data JPA, Hibernate, Spring Boot Web, Thymeleaf

---

## Overview

> This migration moves the Photo Album application's database layer from Oracle
> Database to Azure Database for PostgreSQL. The application currently uses Oracle
> JDBC with hardcoded credentials in application.properties. The new architecture
> will:
>
> - Replace Oracle Database with Azure Database for PostgreSQL, eliminating Oracle
>   licensing costs and enabling a fully managed cloud-native database service.
> - Adopt passwordless authentication via Azure Managed Identity, removing
>   hardcoded credentials and aligning with the organisation's security policy
>   that prohibits plaintext secrets in source code or configuration files.
>
> The migration is carried out in two sequential phases: first converting the
> Oracle-specific database layer to PostgreSQL, then securing the connection with
> Managed Identity.

---

## Migration Impact Summary

| Application | Original Service | New Azure Service            | Authentication     | Comments                     |
|-------------|-----------------|------------------------------|--------------------|------------------------------|
| Photo Album | Oracle Database | Azure Database for PostgreSQL| Managed Identity   | Migrate Oracle to PostgreSQL |

---

## Migration Tasks

### Task 1 — Migrate Oracle Database to PostgreSQL

Migrate the application database layer from Oracle Database to Azure Database for
PostgreSQL. This includes replacing the Oracle JDBC driver with the PostgreSQL
driver, updating datasource configuration, converting Oracle-specific SQL syntax,
and replacing Oracle dialect settings with PostgreSQL equivalents.

### Task 2 — Enable Managed Identity for PostgreSQL

Migrate the PostgreSQL datasource authentication from password-based credentials
to Azure Managed Identity. This removes the hardcoded username and password from
`application.properties` and `application-docker.properties`, ensuring secrets
are never stored in source code or configuration files, in compliance with the
organisation's security policy.
