## Security Compliance

**Purpose**: Describe how to validate CVEs (Common Vulnerabilities and Exposures) in project dependencies and fix security issues.

**Condition**: Only include this section when the user explicitly specifies security requirements (e.g., "CVE clean", "no CVE issues", "fix security issues").

**Template**:

**Description**: [Brief description of security goal from user input]

**Requirements**:
  The original security requirements from user input

**Environment Configuration**:
  Runtime environment established by previous tasks (e.g., Java Home, .NET runtime).
  Build tool established by previous tasks (e.g., Maven/Gradle, dotnet).

**App Scope**:
  The app folders that this task will operate

**Skills**:
  - Skill Name: validate-cves-and-fix
    - Skill Location: builtin
  - Skill Name: [additional skill if needed]
    - Skill Location: [Skill location]