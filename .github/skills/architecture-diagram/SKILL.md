---
name: architecture-diagram
description: Generate architecture diagram from assessment results
---

# Architecture Diagram

This skill generates a simple, clear architecture diagram based on the application assessment results.

## When to Use This Skill

Use this skill when you need to:

- Visualize application architecture after running assessment
- Understand the high-level structure of the assessed application
- Get a quick overview of application layers, dependencies, and data flow
- Share architecture understanding with stakeholders

## What This Skill Does

This skill creates a visual architecture diagram by analyzing the codebase:

1. **Analyze Project Structure**:
   - Examine project files and directory structure
   - Analyze build files:
     - Java: pom.xml, build.gradle, settings.gradle
     - .NET: *.csproj, *.sln
   - Review configuration files:
     - application.properties, appsettings.json
     - database configs, API configs
   - Scan key source files to understand patterns
   - Extract:
     - Application type and framework
     - Major dependencies and libraries
     - Data access patterns
     - External integrations
     - Technology stack

2. **Analyze Architecture**:
   - Identify application layers (UI, Business Logic, Data Access)
   - Detect data storage technologies (databases, caches, file systems)
   - Map external service dependencies
   - Understand component relationships

3. **Generate Diagram**:
   - Create a Mermaid C4 or flowchart diagram
   - Focus on high-level architecture, not detailed components
   - Show key layers, dependencies, and data flow
   - Keep it simple and readable
   - **Important**: Follow GitHub-compatible Mermaid syntax:
     - Avoid special characters (@, #, $, etc.) in arrow labels
     - Use plain text descriptions instead
     - Test rendering compatibility with GitHub
   - Save to `.github/modernize/architecture-diagram.md`

## Input Parameters

- `workspace-path` (optional): Path to the project to analyze (defaults to current directory)

## How to Use

### Prerequisites

- No special prerequisites required
- Works with Java and .NET projects only
- Best used after running `assessment` skill to understand the context

### Triggering Diagram Generation

Simply express the intent to visualize the architecture. Example prompts:

- "Generate architecture diagram from assessment"
- "Show me the application architecture"
- "Create a visual diagram of the assessed application"
- "Visualize the architecture based on assessment results"

The diagram generation process automatically:
- Analyzes project files (build files, configs, source structure)
- Identifies application structure and dependencies
- Creates a Mermaid diagram showing:
  - Application layers (e.g., Presentation, Business, Data)
  - Key frameworks and libraries
  - Data storage components
  - External service integrations
- Saves diagram to `.github/modernize/architecture-diagram.md`

## Diagram Output

The generated diagram will be saved to:

- `.github/modernize/architecture-diagram.md`

**File Structure**: The output file should contain only the diagram with minimal introduction:

```markdown
# Architecture Diagram

A brief introduction (1-2 sentences).

## Application Architecture

```mermaid
[Mermaid diagram showing application architecture]
```


**IMPORTANT - Do NOT include these sections**:
- "Overview" section with detailed text descriptions of the application
- "Code Structure" section listing packages and directories
- "Technology Stack" table listing frameworks and libraries
- "Assessment Summary" table with issues or findings
- "Migration Considerations" or recommendations section
- Any markdown text, lists, or tables outside the Mermaid diagram

**What TO include**:
The Mermaid diagram should be comprehensive and show:
- Application layers with technology information
- Key frameworks and libraries (in the diagram)
- Data storage components (in the diagram)
- External service integrations (in the diagram)
- Data flow with descriptive arrows (in the diagram)

The diagram includes:
- **Application Layers**: High-level architectural layers
- **Technology Stack**: Key frameworks, libraries, and tools
- **Data Storage**: Databases, caches, file systems
- **External Dependencies**: Third-party services and APIs
- **Data Flow**: How data moves through the system (simplified)

**IMPORTANT**: All of the above information should be **inside the Mermaid diagram itself** as part of the visual representation. Do not create separate text sections, tables, or lists for this information outside the diagram.

## Diagram Style

The diagram is intentionally simple and focused:

✅ **Include**:
- High-level application layers
- Major technology choices (frameworks, libraries)
- Data storage types (specific database names like "PostgreSQL", "Redis")
- Key external integrations (APIs, services)
- Simplified data flow arrows

❌ **Exclude**:
- Detailed class structures
- Individual components or methods
- Migration directions (covered in separate planning)
- Low-level implementation details

**Important**: Put all architectural information (technologies, databases, services) **inside the Mermaid diagram boxes and arrows**, not in separate text sections outside the diagram.

## Success Criteria

Diagram generation is complete when:
- ✅ Project structure and files analyzed successfully
- ✅ Architecture analyzed and key components identified
- ✅ Mermaid diagram generated with clear, readable structure
- ✅ Diagram includes technology names, frameworks, data storage, and external dependencies
- ✅ No separate text sections for "Overview", "Code Structure", or technology tables
- ✅ Diagram saved to `.github/modernize/architecture-diagram.md`
- ✅ Diagram is viewable in markdown preview

## Error Handling

**Unsupported Project Type**:
- Only supports Java and .NET projects
- Provide clear message for unsupported project types

**Insufficient Architecture Information**:
- Generate a basic diagram from available data
- Indicate which information is missing or unclear

For any failure, provide clear error messages and next steps.
