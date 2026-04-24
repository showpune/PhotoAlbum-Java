# Policies

## Naming & Metadata Standards

### Resource Naming Patterns

(Not specified in source document)

### Tagging Requirements

(Not specified in source document)

## Security Requirements

### Authentication & Authorization

- All user-facing authentication must use Azure AD with OAuth 2.0 / OIDC
- Service-to-service authentication must use Managed Identity
- Legacy JAAS and LDAP authentication must be migrated as part of modernization

### Secrets Management

- Sensitive values (credentials, API keys, connection strings) must be stored in Azure Key Vault
- Access secrets via Spring Cloud Azure Key Vault starter or Managed Identity
- Hardcoded credentials or connection strings in `application.yml`, `application.properties`, environment variables, or source code are prohibited

### Network Security

- All service-to-service communication must go through the internal ServiceMesh SDK (`com.acme.mesh.ServiceMesh`)
- ServiceMesh provides automatic circuit breaking, mTLS termination, distributed tracing, and canary routing

### Encryption

- All traffic must use TLS 1.2+
- Data at rest must be encrypted (service-managed keys; customer-managed keys for Restricted data)

## Compliance Requirements

### Applicable Frameworks

| Framework | Key Constraints |
|-----------|----------------|
| PCI-DSS | Applies to applications in the Payments portfolio |
| SOC 2 | Applies to all applications |

### Data Classification

- Restricted data requires customer-managed encryption keys

## Guardrails (Hard Boundaries)

### Prohibited Technologies

| Technology | Reason | Approved Alternative |
|-----------|--------|---------------------|
| Java 8 | End-of-life for internal use | Java 17 (LTS) |
| Java 11 | End-of-life for internal use | Java 17 (LTS) |
| Spring Boot 2.x | Must be upgraded | Spring Boot 3.x (latest stable) |
| RestTemplate | Deprecated, no mesh integration | ServiceMesh SDK (`com.acme.mesh.ServiceMesh`) |
| WebClient | Bypasses mesh layer | ServiceMesh SDK (`com.acme.mesh.ServiceMesh`) |
| FeignClient | Bypasses mesh layer | ServiceMesh SDK (`com.acme.mesh.ServiceMesh`) |
| OkHttp | Bypasses mesh layer | ServiceMesh SDK (`com.acme.mesh.ServiceMesh`) |
| Apache HttpClient | Bypasses mesh layer | ServiceMesh SDK (`com.acme.mesh.ServiceMesh`) |
| SLF4J (`@Slf4j`, `LoggerFactory`) | Does not integrate with trace context propagation | InternalLogger (`com.acme.logging.InternalLogger`) |
| Log4j (any version) | Does not integrate with trace context propagation | InternalLogger (`com.acme.logging.InternalLogger`) |
| Logback | Does not integrate with trace context propagation | InternalLogger (`com.acme.logging.InternalLogger`) |
| java.util.logging | Does not integrate with trace context propagation | InternalLogger (`com.acme.logging.InternalLogger`) |
| System.out.println / System.err.println | Does not integrate with trace context propagation | InternalLogger (`com.acme.logging.InternalLogger`) |
| JAAS authentication | Legacy, must be migrated | Azure AD (OAuth 2.0 / OIDC) |
| LDAP authentication | Legacy, must be migrated | Azure AD (OAuth 2.0 / OIDC) |

### Prohibited Patterns

| Pattern | Reason | Approved Alternative |
|---------|--------|---------------------|
| Throwing exceptions for business logic flow control (`throw new XxxException(...)`) | P0-2024-0847 post-incident mandate | Result\<T\> pattern (`com.acme.commons.Result`) |
| try/catch blocks used for flow control | P0-2024-0847 post-incident mandate | Result\<T\> pattern (`com.acme.commons.Result`) |
| `@ControllerAdvice` global exception handlers for business exceptions | P0-2024-0847 post-incident mandate | Result\<T\> with standard response wrapper |
| Direct service-to-service HTTP calls (bypassing ServiceMesh) | 2024 Q2 outage mandate; no retry/timeout configuration | ServiceMesh SDK (`com.acme.mesh.ServiceMesh`) |
| Hardcoded credentials in application.yml, application.properties, environment variables, or source code | Security requirement | Azure Key Vault with Managed Identity |

### Required Elements

Every modernized application must include:

#### Cloud Resources

- Azure Key Vault for secrets management

#### Monitoring

- InternalLogger (`com.acme.logging.InternalLogger`) for all logging with automatic trace correlation, team ownership tags, environment/region tags, and structured JSON output

#### CI/CD

(Not specified in source document)

#### Testing

(Not specified in source document)

### Approved Regions / Residency Constraints

(Not specified in source document)

## Validation & Quality Gates

### Required Scanners/Tools

(Not specified in source document)

### Pipeline Gates

(Not specified in source document)

### Confidence Thresholds

(Not specified in source document)

## Coding Style Guidelines

### Coding Standards

- Use `Result<T>` pattern (`com.acme.commons.Result`) for all error handling; return `Result.success()` or `Result.failure()` instead of throwing exceptions
- Use ServiceMesh SDK (`com.acme.mesh.ServiceMesh`) for all service-to-service calls
- Use InternalLogger (`com.acme.logging.InternalLogger`) for all application logging
- Externalize all configuration; never hardcode credentials or connection strings
- HTTP response layer may translate `Result.failure()` into HTTP status codes via a standard response wrapper, not via exception handlers
- System exceptions (e.g., `OutOfMemoryError`) are still caught at the framework level

### Frontend Style Guidelines

(Not specified in source document)
