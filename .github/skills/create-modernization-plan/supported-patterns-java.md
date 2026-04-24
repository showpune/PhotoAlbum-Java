## Supported Task Patterns

The following are the task patterns supported by the modernize CLI. These patterns are used to identify the modernization tasks that need to be performed based on the user's input.

The patterns are categorized into two groups, and they should be treated differently if picked:

* Patterns with skill definitions: These patterns have pre-defined skills that can be used to execute the tasks. If a task matches one of these patterns, the corresponding skill should be used in the task plan.
* Patterns without skill definitions: These patterns do not have pre-defined skills. If a task matches one of these patterns, the description should be used to guide the AI in performing the required tasks.
   **IMPORTANT**: The pattern name should NEVER be used as the skill name in the generated plan and tasks.json. They are meant to guide the task generation, not to be directly used as skills.


### Task Patterns with Skill Definitions
These patterns have pre-defined skills to assist in their execution. When they are selected in a modernization plan, the corresponding skills should be used.
Each of the item is written in the following format: `- **skill-name**: skill-description`.

- **infrastructure-bicep-generation**: Generate Bicep IaC files for Azure infrastructure provisioning
- **infrastructure-terraform-generation**: Generate Terraform IaC files for Azure infrastructure provisioning
- **migrate-cache-related-code-to-redis**: Provides knowledge for migrating cache related code to use Redis, and potentially to Azure Managed Redis / Azure Cache for Redis (retiring) while following best practices. Use this skill when users want to migrate their cache related code to use Redis, such as Apache Commons JCS, DynaCache, Embedded cache, JCache, OSCache, ShiftOne, Oracle Coherence, etc., or local Redis to Azure Managed Redis / Azure Cache for Redis (retiring) with secure authentication changes.
- **migration-AWS-secrets-manager-to-azure-key-vault**: Migrate AWS Secrets Manager to Azure Key Vault
- **migration-activemq-servicebus**: Migrate from ActiveMQ Artemis to Azure Service Bus for messaging.
- **migration-amqp-rabbitmq-servicebus**: Migrate from RabbitMQ with AMQP to Azure Service Bus for messaging.
- **migration-ant-project-to-maven-project**: Migrate current project from Ant project to Maven project
- **migration-certificate-management-to-azure-key-vault**: Migrate certificate management to Azure Key Vault
- **migration-confluent-cloud-kafka**: Migrate Kafka to Apache Kafka on Confluent Cloud with Entra ID authentication
- **migration-cryptography-operations-to-azure-key-vault**: Migrate local crypto and signature to use Azure Key Vault Key
- **migration-eclipse-project-to-maven-project**: Migrate current project from eclipse project to maven project
- **migration-java-ee-amqp-rabbitmq-servicebus**: Migrate from RabbitMQ with AMQP to Azure Service Bus for messaging in Java EE/Jakarta EE applications.
- **migration-javax.email-send-to-azure-communication-service-email**: Migrate JavaMail to Azure Communication Service
- **migration-jax-rpc-to-jax-ws**: Migrate from JAX-RPC to JAX-WS for web services. JAX-RPC is deprecated and JAX-WS is the recommended alternative.
- **migration-kafka-to-eventhubs**: Migrate from Kafka to Azure Event Hubs for Apache Kafka with managed identity for secure, credential-free authentication.
- **migration-log-to-console**: Migrate file logging to console logging
- **migration-mi-azure-sql**: Migrate a Java projects from password-based authentication to Azure Managed Identity for connecting to Azure SQL Database.
- **migration-mi-azuresql-azure-sdk-21v-china**: Migrate from SQL Database to Azure SQL Database with Azure SDK and managed identity in Mooncake for secure, credential-free authentication.
- **migration-mi-azuresql-azure-sdk-public-cloud**: Migrate from SQL Database to Azure SQL Database with Azure SDK and managed identity for secure, credential-free authentication.
- **migration-mi-cassandra-azure-sdk-public-cloud**: Migrate Java projects to connect to Azure Cosmos DB for Cassandra using managed identity in Azure public cloud.
- **migration-mi-eventhub-spring**: Migrate a Java projects from password-based authentication to Azure Managed Identity for connecting to Azure Event Hubs via Spring
- **migration-mi-mariadb-azure-sdk-public-cloud**: Migrate from MariaDB to Azure Database for MariaDB with managed identity for secure, credential-free authentication.
- **migration-mi-mongodb-azure-sdk-public-cloud**: Migrate from MongoDB to Azure Cosmos DB for MongoDB with managed identity for a fully managed, scalable database service with MongoDB API support.
- **migration-mi-mysql**: Migrate Java projects from password-based authentication to Azure Managed Identity for connecting to Azure Database for MySQL.
- **migration-mi-mysql-azure-sdk-21v-china**: Migrate from MySQL to Azure Database for MySQL with Azure SDK and managed identity in the Mooncake cloud for secure, credential-free authentication.
- **migration-mi-mysql-azure-sdk-public-cloud**: Migrate from MySQL to Azure Database for MySQL with Azure SDK and managed identity for secure, credential-free authentication.
- **migration-mi-postgresql**: Migrate Java projects from password-based authentication to Azure Managed Identity for connecting to Azure Database for PostgreSQL.
- **migration-mi-postgresql-azure-sdk-21v-china**: Migrate from PostgreSQL to Azure Database for PostgreSQL with Azure SDK and managed identity in the Mooncake cloud for secure, credential-free authentication.
- **migration-mi-postgresql-azure-sdk-public-cloud**: Migrate from PostgreSQL to Azure Database for PostgreSQL with Azure SDK and managed identity for secure, credential-free authentication.
- **migration-on-premises-user-authentication-to-microsoft-entra-id**: Migrate the user authentication to Microsoft Entra ID authentication
- **migration-oracle-to-postgresql**: Migrate from Oracle DB to PostgreSQL
- **migration-plaintext-credential-to-azure-keyvault**: Migrate plaintext credentials to Azure Key Vault
- **migration-s3-to-azure-blob-storage**: Migrate AWS S3 to Azure Blob Storage
- **migration-spring-jms-rabbitmq-servicebus**: Migrate from RabbitMQ with JMS to Azure Service Bus for a managed messaging service with JMS API support.
- **migration-sqs-to-servicebus**: Migrate AWS SQS to Azure Service Bus
- **migration-sybase-ase-to-azure-sql-database**: Migrate Sybase ASE to Azure SQL Database

### Task Patterns without Skill Definitions
These patterns DO NOT have pre-defined skills. The pattern name and description define the modernization scenario, NOT A SKILL. They are in the format of `- **pattern-name**: pattern-description`.

A pattern should be selected if it matches one of the customer's requirements, and there are no skills supporting this requirement.

**IMPORTANT**:
- NEVER write the pattern name as skill name in the generated plan.
- Tasks generated from these patterns must have NO skill assigned. Do not reuse any skill from the "Task Patterns with Skill Definitions" section, even if a skill targets a similar technology or appears related.

- **amazon-kinesis-to-azure-event-hubs**: Amazon Kinesis to Azure Event Hubs
- **amazon-sns-to-azure-service-bus**: Amazon SNS to Azure Service Bus
- **apache-pulsar-to-azure-event-hubs**: Apache Pulsar to Azure Event Hubs
- **aws-lambda-to-azure-functions**: AWS Lambda to Azure Functions
- **firebird-to-azure-postgresql**: Firebird to Azure PostgreSQL
- **google-cloud-bigtable-to-azure-cosmos-db**: Google Cloud Bigtable to Azure Cosmos DB
- **google-cloud-functions-to-azure-functions**: Google Cloud Functions to Azure Functions
- **google-cloud-pub-sub-to-azure-service-bus**: Google Cloud Pub/Sub to Azure Service Bus
- **google-cloud-spanner-to-azure-postgresql**: Google Cloud Spanner to Azure PostgreSQL
- **google-cloud-storage-to-azure-blob-storage**: Google Cloud Storage to Azure Blob Storage
- **google-firestore-to-azure-cosmos-db**: Google Firestore to Azure Cosmos DB
- **ibm-db2-to-azure-postgresql**: IBM DB2 to Azure PostgreSQL
- **ibm-mq-jms-to-azure-service-bus**: IBM MQ JMS to Azure Service Bus
- **migration-local-certificate-management-to-azure-key-vault**: Local certificate management to Azure Key Vault
- **migration-local-files-to-mounted-azure-storage**: Local files to mounted Azure Storage paths (starts with `${AZURE_MOUNT_PATH:/mnt/azure}`)
- **quartz-scheduler-to-azure-functions**: Quartz Scheduler to Azure Functions
- **solace-pubsub-to-azure-service-bus**: Solace PubSub+ to Azure Service Bus
- **spring-batch-to-azure-durable-functions**: Spring Batch to Azure Durable Functions
- **spring-cloud-config-to-azure-app-configuration**: Spring Cloud Config to Azure App Configuration
- **sqlite-to-azure-postgresql**: SQLite to Azure PostgreSQL
- **sybase-ase-to-azure-postgresql**: Sybase ASE to Azure Database for PostgreSQL
- **tibco-ems-jms-to-azure-service-bus**: TIBCO EMS JMS to Azure Service Bus
