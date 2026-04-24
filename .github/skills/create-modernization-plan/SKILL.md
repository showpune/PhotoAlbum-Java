---
name: create-modernization-plan
description: Create a modernization plan to migrate the project to Azure
---

# Create modernization plan

This skill is used to create a modernization plan to migrate the a given project to Azure

## User Input

modernization-prompt: The user input to generate the modernization plan
modernization-work-folder (Mandatory): The folder to save the modernization plan
github-issue-link (Optional): A github issue to track the modernization status, to be filled into plan template
assessment-report (Optional): A assessment report for the project will be modernized, it will provide the data about the project for modernization
plan-name (Optional): The plan name to be filled into plan template
language (Mandatory): The programming language of the project (java or dotnet)

## Supported Task Patterns

Read the supported patterns file based on the language:
- For .NET projects: Read `supported-patterns-dotnet.md`
- For all other projects: Read `supported-patterns-java.md`. Default option.

These files contain the list of supported task patterns with and without skill definitions. If a skill is available, the skill location should be set to `builtin`.

## Workflow

Given the user input, do this:

1. Double Check the issues
   **IMPORTANT**:
   - If you are given an assessment-report, you need to double check if the issue really exist in current project. If not, please ignore this issue when you generate the plan

2. **Load context**: Retrieve information for plan, you can read
    1) Analysis the supported patterns to find the right tasks for the issues
    2) Analysis modernization requirement from user input

3. **Generate plan and tasks**: Generate plan.md and tasks.json using the appropriate templates:

    **Template Selection**:
    - Use **plan-template.md** for code migration, containerization, and deployment tasks
    - Use **security-plan-template.md** ONLY when user explicitly specifies security requirements (e.g., "CVE clean", "no CVE issues", "fix CVE issues", "fix vulnerabilities", "fix security issues"). The security task order should be after all the upgrade and transform tasks and before the deployment tasks in the generated plan.
    - Use **infra-plan-template.md** ONLY when user explicitly requests infrastructure (e.g., "prepare infrastructure", "create landing zone", "provision resources", "generate Bicep/Terraform")

    **Plan Generation**:
    1) Follow the structure of the selected template to generate the plan
    2) Follow the rules defined in the template to fill in the sections with relevant information based on the analysis of user input and content of mentioned files
    3) Save the plan in folder ${modernization-work-folder} with the filename plan.md. If a plan already exists, overwrite it.
    4) Generate a separate tasks.json file following the tasks-schema.json schema with all upgrade, transform, integration test, infrastructure, containerization, and deployment tasks
    5) Save the tasks in folder ${modernization-work-folder} with the filename tasks.json. If tasks.json already exists, overwrite it.


    **IMPORTANT**: The plan.md should NOT contain the detailed task breakdown. Those details go into tasks.json for better tracking and programmatic access.

    **Task Breakdown Rules**: When creating tasks for tasks.json and plan.md:
    - Purpose: Break down coding work into discrete migration tasks. Each task represents a user-requested migration from one service/component to another, or a specific business logic modernization.
    - Create tasks ONLY based on what the user explicitly requested - do not infer or add implicit tasks
    - Group related changes that serve a single user goal into one task (e.g., all changes needed to migrate to PostgreSQL)
    - Find a matched skill / pattern for the task, following the following priority order.
      1. Skills available for the project, which will be listed in the `skill` tool description.
      2. Patterns that will be attached and available at plan execution phase, listed in the supported patterns file.
      3. Otherwise if no relevant pattern is available for the task pattern, use the prompt segment from the user directly. DO NOT expand the request scope.
    - **IMPORTANT**:
      - You MUST NOT use the pattern name as the skill name in the generated plan and tasks.json.
      - If there are similar skills defined in project skill `.github/skills/` versus other skills, MUST use the one defined in project.
      - Skills must be fully matched. For migration scenarios, both the source product and target product must match the task intent.
    - Each task should be independently testable with integration tests
    - Do not add tests for unimpacted code or existing functionality unless user requested
    - **IMPORTANT**: Do NOT read individual skill files at this stage; Do Not include the skill detail in the tasks.

    **Integration Test Task Rules**: When user explicitly requests integration testing (e.g., "add integration tests", "generate integration tests", "test the migration"):
    - Add an integration test task with type "integrationTest" after all transform/upgrade tasks but before containerization tasks
    - This integration test task should:
      - Have id format: "{sequence}-integrationTest" where sequence is the next number after the last migration task (e.g., if last migration is 001, use "002-integrationTest")
      - Have description: "Generate and run integration tests for Azure service migrations"
      - Have dependencies on ALL transform and upgrade task ids (so it runs after all migrations are complete)
      - Have requirements: "Generate Layer 1 (Local Integration with TestContainers) and Layer 2 (Smoke Tests) for all Azure service migrations"
      - Have layers: [1, 2] (only Layer 1 and Layer 2 tests)
      - Omit environmentConfiguration unless explicitly provided by user input
    - The integration test task appears in plan.md as a separate section after migration tasks but before containerization

    **Java Upgrade Task Guidelines**: Only add an upgrade task if the user explicitly requests it. You must refer to the ./java-upgrade-guideline.md for specific rules and guidelines when creating Java upgrade tasks.

    **.NET Upgrade Task Guidelines**: You must refer to the ./dotnet-upgrade-guideline.md for specific rules and guidelines when creating .NET upgrade tasks.

    **IMPORTANT**: The upgrade task must be the first task in the task list because subsequent transform tasks (e.g., migrating to Azure services) depend on the upgraded runtime and project format.

4. **Clarification**: If there are any open issues or ambiguities that need user input:
    1) Write all open issues to `${modernization-work-folder}/clarifications.json` as a JSON array. Each entry must follow this exact format:
       ```json
       [
         { "question": "What is your preferred authentication method for accessing Azure Storage?", "answer": "" }
       ]
       ```
       Leave every `answer` field empty — the CLI will collect answers from the user interactively.
    2) Do NOT embed clarification questions in `plan.md`. Do NOT wait for user input.
       The CLI handles answer collection and plan refinement as a separate post-processing step.

## Completion Criteria

1. If there are open issues or ambiguities, they are written to `clarifications.json` in the plan folder
2. The modernization task list is built
3. The modernization task list MUST be scoped according to user input
4. DON'T RUN the plan if user does not explicitly ask you to run the plan
