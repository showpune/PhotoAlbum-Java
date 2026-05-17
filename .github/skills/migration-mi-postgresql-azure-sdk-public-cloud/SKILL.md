---
name: migration-mi-postgresql-azure-sdk-public-cloud
description: Migrate from PostgreSQL to Azure Database for PostgreSQL with Azure SDK and managed identity for secure, credential-free authentication.
---

# mi-postgresql-azure-sdk-public-cloud

## Overview

Your job is to migrate from PostgreSQL to Azure Database for PostgreSQL with Azure SDK and managed identity for secure, credential-free authentication.
Below are the specific instructions for different migration tasks, please follow the instructions to complete the migration.

## Knowledge Base Content

* Title: Upgrade code to use Managed Identity in Azure PostgreSQL (Public Cloud)
* Description: Migrate Azure PostgreSQL authentication to a managed identity using AzurePostgresqlAuthenticationPlugin.
* Content: 

## Upgrade code to use Managed Identity in Azure PostgreSQL (Public Cloud)

Migrate Azure PostgreSQL authentication to a managed identity using AzurePostgresqlAuthenticationPlugin.

### Search code
Search files from workspace using below patterns:
- Glob pattern to find files: `**/*.java`
- Regex pattern to find code lines: `DriverManager`

### Instruction

Your task is to migrate a java file from using a connection string to using passwordless managed identity for authentication in Azure PostgreSQL (Public Cloud).
Ensure the resulting code is clean, efficient, and preserves the original functionality.
Please ensure to follow the guidance below to complete this task:
1. Remove password Usage: Eliminate the hardcoded password in the connection string.
2. Replace the value of user name with managed identity for the database connection: Please use the name of managed identity to replace the value of the user name for PostgreSQL database connection.
3. Add Authentication Plugin Config: Please add a new string variable for authenticationPluginClassNameConfig. The value should be exactly this string "&authenticationPluginClassName=com.azure.identity.extensions.jdbc.postgresql.AzurePostgresqlAuthenticationPlugin".
4. Append the mentioned authenticationPluginClassNameConfig to the connection string url.
5. Use the updated connection string url to get Connection.

Below are the APIs provided for your reference:

Class: DriverManager
  Description: The basic service for managing a set of JDBC drivers.
  Package: java.sql
  Methods:
    getConnection(String url): Attempts to establish a connection to the given database URL.
    getConnection(String url, Properties info): Attempts to establish a connection to the given database URL.



## Add dependency for Managed Identity in Azure PostgreSQL (Public Cloud)

Add azure-identity-extensions dependency

### Search code
Search files from workspace using below patterns:
- Glob pattern to find files: `**/{pom.xml,build.gradle}`
- Regex pattern to find code lines: `postgresql`

### Instruction

Please add the azure-identity-extensions dependency:
groupId: com.azure
artifactId: azure-identity-extensions
version: 1.2.2

Note:  Please check the latest version of the dependency, and upgrade the version if possible.



## Add properties for Managed Identity in Azure PostgreSQL (Public Cloud)

Add Azure managed identity name in configuration.

### Search code
Search files from workspace using below patterns:
- Glob pattern to find files: `**/application{,-*}.{yml,yaml,properties}`
- Regex pattern to find code lines: `.*`

### Instruction

Your task is to migrate a configuration file to use managed identity for authentication in Azure PostgreSQL instead of a password.
If the configuration file is yaml, please ensure the indentation and format is correct and consistent with the rest of the file.

1. Add the configuration for Azure managed identity name.
  The name of Azure managed identity is used as user in database connection.

2. Remove the configuration for the password of the **PostgreSQL** database:
  - Removing password segments from JDBC connection strings (typically after the & symbol)
  - Removing the password property from the configuration file
Note: please do not remove the password property if it is used for other purposes.