# Java Upgrade Task Guidelines

Only add an upgrade task if the user explicitly requests it. The upgrade task must be the first task if it exists.

## Latest Stable Versions

- Java: 25
- Spring Boot: 4.x
- Spring Framework: 7.x

## Supported Upgrade Versions

- Java: 11, 17, 21, 25
- Spring Boot: 3.x, 4.x
- Spring Framework: 6.x, 7.x

## Framework Compatibility

| Spring Boot | Spring Framework | Jakarta EE | Minimum Java | Maximum Java |
|-------------|:----------------:|:----------:|:------------:|:------------:|
| 2.x | 5.x | JavaEE (javax.*) | 8 | 11 |
| 3.x | 6.x | Jakarta EE (jakarta.*) | 17 | 21 |
| 4.x | 7.x | Jakarta EE (jakarta.*) | 25 | 25 |

## Upgrade Task Types and Included Changes

| Task Type | Spring Framework Upgrade | Jakarta EE Migration (javax.* → jakarta.*) | JDK/Java |
|-----------|:------------------------:|:------------------------------------------:|:-----------:|
| Spring Boot 4.x upgrade | 7.x | ✓ | 25 |
| Spring Boot 3.x upgrade | 6.x | ✓ | 21 |
| Spring Framework 7.x upgrade | — | ✓ | 25 |
| Spring Framework 6.x upgrade | — | ✓ | 21 |
| Jakarta EE upgrade | — | ✓ | 21 |
| JDK/Java upgrade | — | — | to specified version |

## Java Task Selection Rules

When selecting the Java upgrade task type, follow these rules in order:

- **Rule 1 — No redundant sub-tasks**: Each upgrade type (Spring Boot, Spring Framework, Jakarta EE, JDK/Java) is hierarchical — higher-level tasks already include lower-level ones. Never create a lower-level task that is already covered by a selected higher-level task. For example, if a Spring Boot 4.x upgrade task is selected (which already includes JDK 25), do NOT also create a separate JDK/Java upgrade task.
- **Rule 2 — User-specified request doesn't fully match system state**: Only select the highest-level task applicable to the system state and prompt the user to clarify. For example, if the user asks to "upgrade to JDK 17" but the project contains Spring Boot 2.x, only create a Spring Boot 4.x upgrade task (which includes JDK 25 upgrade), but NOT a separate JDK/Java upgrade task for Java 17. Inform the user about the included changes in the selected task and ask them to confirm or clarify.
- **Rule 3 — User-specified request matches system state**: Select the most closely matching task type that directly matches the user's request and fits the system. For example, if the user asks to "upgrade JDK" and the JDK is outdated, create a JDK/Java upgrade task — NOT a higher-level Spring Boot or Spring Framework upgrade task.