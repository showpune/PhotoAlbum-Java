# Targets

## Target Frameworks

| Language | Target Version | Notes |
|----------|---------------|-------|
| Java | 17 (LTS) | Java 8 and 11 are end-of-life for internal use |
| Spring Boot | 3.x (latest stable) | All Spring Boot 2.x applications must be upgraded |
| Maven | 3.9+ | Gradle is acceptable where already in use |

## Target Compute Services

| Platform | Use When |
|----------|----------|
| Azure Kubernetes Service (AKS) | Default for all services |
| Azure App Service | Simple web apps under 5K LOC with no async processing |

## Target Data Services

| Service | Use When |
|---------|----------|
| Azure Key Vault | Storing sensitive values (credentials, API keys, connection strings) |

## Target Integration Services

| Service | Use When |
|---------|----------|
| ServiceMesh SDK (`com.acme.mesh.ServiceMesh`) | All service-to-service communication (provides circuit breaking, mTLS, distributed tracing, canary routing) |

## Target Libraries

| Source | Target | Notes |
|--------|--------|-------|
| RestTemplate | ServiceMesh SDK (`com.acme.mesh.ServiceMesh`) | RestTemplate is deprecated, no mesh integration |
| WebClient | ServiceMesh SDK (`com.acme.mesh.ServiceMesh`) | Bypasses mesh layer |
| FeignClient | ServiceMesh SDK (`com.acme.mesh.ServiceMesh`) | Bypasses mesh layer |
| OkHttp / Apache HttpClient | ServiceMesh SDK (`com.acme.mesh.ServiceMesh`) | Direct HTTP client libraries bypass mesh layer |
| SLF4J (`@Slf4j`, `LoggerFactory`) | InternalLogger (`com.acme.logging.InternalLogger`) | Does not integrate with trace context propagation |
| Log4j (any version) | InternalLogger (`com.acme.logging.InternalLogger`) | Does not integrate with trace context propagation |
| Logback | InternalLogger (`com.acme.logging.InternalLogger`) | Does not integrate with trace context propagation |
| java.util.logging | InternalLogger (`com.acme.logging.InternalLogger`) | Does not integrate with trace context propagation |
| System.out.println / System.err.println | InternalLogger (`com.acme.logging.InternalLogger`) | Does not integrate with trace context propagation |
| Exception-based error handling | Result\<T\> (`com.acme.commons.Result`) | Mandatory per P0-2024-0847 post-incident mandate |
| JAAS authentication | Azure AD (OAuth 2.0 / OIDC) + Managed Identity | Legacy auth must be migrated |
| LDAP authentication | Azure AD (OAuth 2.0 / OIDC) + Managed Identity | Legacy auth must be migrated |

## Target Artifacts

| Artifact | Location | Notes |
|----------|----------|-------|
| Container base image (build) | `mcr.microsoft.com/openjdk/jdk:17-ubuntu` | Build stage |
| Container base image (runtime) | `mcr.microsoft.com/openjdk/jdk:17-distroless` | Runtime stage |
