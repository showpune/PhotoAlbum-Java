# Charter

## Metadata

| Field | Value |
|-------|-------|
| Playbook Name | Acme Corp Modernization Playbook |
| Version | 1.0 |
| Changelog | Initial version based on Internal Technology Guidelines (2025-01-15) |

## Scope

### Covered Applications and Languages

- **Languages:** Java
- **Portfolios:** Payments, Commerce
- **Timeline:** All covered applications must be modernized by Q4 2026

### Application Types

**Included:**

- All Java applications in the Payments and Commerce portfolios

**Excluded:**

- Not specified in source document

### Custom Libraries

- `com.acme.mesh.ServiceMesh` — Internal service mesh SDK for service-to-service communication (circuit breaking, mTLS, distributed tracing, canary routing)
- `com.acme.commons.Result` — Result\<T\> pattern for explicit error handling
- `com.acme.logging.InternalLogger` — Internal structured logging framework with trace context propagation

### Constraints

- Java 8 and 11 are end-of-life for internal use
- All Spring Boot 2.x applications must be upgraded
- Applications in the Payments portfolio are subject to PCI-DSS requirements
- All applications must comply with SOC 2 controls

## Modernization Strategy (6R Guidelines)

| Application Type | Default Strategy | Override Conditions |
|------------------|-----------------|---------------------|
| Java services (Payments, Commerce) | Replatform to Azure Kubernetes Service (AKS) | Simple web apps under 5K LOC with no async processing → Replatform to Azure App Service |

## Principles

- Standardize on internal libraries for service communication, error handling, and logging to ensure consistent observability and reliability
- Enforce security by default through managed identity, centralized secrets management, and encrypted communications
- Use explicit error handling over exception-based flow control to prevent cascading failures
