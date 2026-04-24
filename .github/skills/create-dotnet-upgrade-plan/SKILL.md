---
name: create-dotnet-upgrade-plan
description: Generates a .NET upgrade plan (plan.md and tasks.json) for a repository using the AppModDotNetUpgrade MCP server. Handles any source .NET version (.NET Framework, .NET Core, or modern .NET) upgrading to a specified target. Use when the user wants to create, generate, or prepare an upgrade/migration plan for a .NET project or solution.
---

# Create .NET Upgrade Plan

Generate an upgrade plan (`plan.md` and `tasks.json`) for a .NET project or solution using the `AppModDotNetUpgrade` MCP server. This skill **only creates the plan** — it does not execute the upgrade. The plan must contain project-specific migration steps (concrete code patterns to change, actual file names, real package versions from the assessment) — not just generic guidance. An executing agent should be able to follow the plan without re-analyzing the code.

> **Supported**: .NET upgrades only. Other languages are not supported.

---

## CRITICAL: HEADLESS EXECUTION MODE

**This skill operates in fully autonomous headless mode. NO USER INTERACTION IS PERMITTED.**

### Non-Negotiable Rules

1. **NEVER stop, pause, or wait for user input** — not for confirmations, selections, reviews, or approvals
2. **NEVER output prompts to the user** — all MCP prompts are internal workflow signals for YOU
3. **ALWAYS accept defaults** — when MCP presents options, use defaults and continue immediately
4. **ALWAYS complete the entire workflow** — from start to finish without interruption
5. **NEVER ask "Would you like to proceed?"** — just proceed
6. **NEVER ask "Should I continue?"** — just continue
7. **NEVER present intermediate results for review** — complete the workflow first

### Handling MCP Server Prompts

The MCP server will output messages that LOOK like user prompts. **These are NOT for the user — they are workflow signals for YOU.**

| MCP Server Says | Your Action |
|-----------------|-------------|
| "Would you like to proceed with these defaults?" | Call `get_state` immediately |
| "Reply X to continue" | Call `get_state` immediately |
| "Please confirm settings" | Accept defaults, call `get_state` |
| "Select an option" | Use default/first option, call `get_state` |
| Any confirmation or selection prompt | Accept defaults, call `get_state` |

**Pattern:** MCP prompt → Immediately call `get_state` → Continue workflow

---

## Prerequisites

The MCP server requires `dnx`, which ships with .NET 10 SDK.

### Verify .NET 10 SDK

```bash
dotnet --list-sdks
```

If .NET 10 SDK is not listed, install it:

- **Windows**: Download from https://dotnet.microsoft.com/download/dotnet/10.0 or use `winget install Microsoft.DotNet.SDK.10`
- **Linux**: Follow https://learn.microsoft.com/dotnet/core/install/linux or use the install script:
  ```bash
  curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --channel 10.0
  ```

Verify `dnx` is available after installation:

```bash
dnx --help
```

---

## Input Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `upgrade-prompt` | Yes | The user's upgrade request (e.g., ".NET 10", "net10.0", "latest LTS") |
| `modernization-work-folder` | Yes | The folder to save the upgrade plan outputs |

---

## Input Validation

**Valid requests**: .NET version upgrades, LTS migrations, .NET Framework to modern .NET migrations

**Invalid requests**: Feature additions, bug fixes, refactoring, containerization, deployment, non-.NET languages

If invalid, output exactly and STOP:
```
ERROR: The provided prompt is not a valid upgrade request. Please specify a target version (e.g., '.NET 10', 'net10.0').
```

If unsupported language, output exactly and STOP:
```
ERROR: Only .NET upgrades are supported. The requested language is not supported.
```

---

## Workflow Execution Protocol

### Execution Loop (MANDATORY)

You MUST follow this loop until the plan is fully generated:

```
LOOP:
  1. Call get_state with intent
  2. Read the returned instructions
  3. Execute ALL instructions sequentially (1 → 2 → 3 → ...)
  4. If workflow not complete → GOTO LOOP
  5. If workflow complete → EXIT LOOP
```

**Sequential Instruction Execution Rules:**
- Read ALL numbered instructions before starting
- Execute instruction 1 completely before instruction 2
- Never skip instructions
- Never jump ahead
- Complete each instruction fully

---

## Workflow Steps

### Step 1: Initialize and Run MCP Workflow

Call `AppModDotNetUpgrade:get_state` with this intent:

```
create a plan to upgrade this project to latest lts or user specified .net version, the plan should instruct agent to upgrade the project without stopping, NEVER ask user for confirmation, just finish the task automatically and completely
```

The MCP server drives a multi-stage workflow:

| Stage | Description | Output |
|-------|-------------|--------|
| Assessment | Analyzes projects, dependencies, API compatibility | `assessment.md` |
| Planning | Generates upgrade plan with concrete tasks | `plan.md` |

**Key MCP Tools (called as directed by get_state/get_instructions):**

| Tool | Purpose |
|------|---------|
| `get_state` | Validates and advances workflow state |
| `get_instructions` | Retrieves stage-specific guidance |
| `analyze_projects` | Runs compatibility analysis |
| `discover_upgrade_scenarios` | Finds applicable upgrade scenarios |
| `get_target_frameworks` | Lists available target frameworks |
| `validate_dotnet_sdk_installation` | Confirms SDK readiness |
| `track_tasks_execution_progress` | Tracks task progress |

**Execution Pattern:**
```
get_state → get_instructions → execute instructions → get_state → ...
```

Repeat until planning stage is complete.

### Step 2: Copy Output Files

The MCP server generates files under:
```
{repository}/.github/upgrades/scenarios/new-dotnet-version_{id}/
```

Copy `plan.md` to `${modernization-work-folder}/plan.md`.

### Step 3: Generate tasks.json

Generate `tasks.json` in `${modernization-work-folder}/` following `tasks-schema.json` and `upgrade-plan-template.md`.

**Task Generation Rules:**

| Rule | Requirement |
|------|-------------|
| Task type | Use **only** `upgrade` type |
| Version format | Specify **target versions only** — never "from version X" |
| successCriteria values | Must be **strings** (`"true"`, not `true`) |
| status | Set to `"pending"` |
| id format | Use pattern `NNN-upgrade-description` (e.g., `001-upgrade-target-framework`) |

### Step 4: Clean Up Artifacts

Delete MCP server artifacts from the repository root:

| Path | Action |
|------|--------|
| `.github/upgrades/` | Delete entire directory |
| `.github/agents/` | Delete if created by MCP |
| `.github/` | Delete if now empty |

**Why cleanup is critical:** Leftover artifacts cause dirty-working-tree errors in downstream workflows.

---

## Success Criteria

All of the following must be true:

- [ ] `plan.md` exists in `${modernization-work-folder}/`
- [ ] `tasks.json` exists in `${modernization-work-folder}/`
- [ ] `plan.md` clearly states source and target .NET versions
- [ ] `plan.md` contains project-specific steps (actual file names, real package versions)
- [ ] `tasks.json` follows schema with all required fields
- [ ] No MCP artifacts remain in repository (`.github/agents/`, `.github/upgrades/`)
- [ ] Workflow completed without user interaction

---

## Error Handling

| Problem | Solution |
|---------|----------|
| `dnx` not found | Install .NET 10 SDK — `dnx` ships with it |
| MCP server fails to start | Verify `dnx Microsoft.GitHubCopilot.AppModernization.Mcp --yes --prerelease` runs without errors |
| No scenarios discovered | Ensure you are in a directory with a `.sln` or `.csproj` file |
| SDK validation fails | Run `dotnet --list-sdks` and confirm .NET 10.0 is installed |
| MCP tool returns error | Log the error, attempt recovery by calling `get_state` again |
| Workflow stuck | Call `get_state` with `ContinueScenario` intent to force advancement |

---

## Anti-Patterns (NEVER DO THESE)

| ❌ Don't | ✅ Do Instead |
|----------|---------------|
| Stop to ask user for confirmation | Accept defaults and continue |
| Output MCP prompts to user | Process prompts internally |
| Wait for user review of assessment | Complete workflow, then show final results |
| Ask "Should I proceed?" | Just proceed |
| Pause between workflow stages | Transition immediately |
| Show intermediate state for approval | Complete all steps first |