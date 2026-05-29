---
name: define-convention
description: Use when defining a new coding convention or deciding whether it should be a skill or steering/instructions file.
---
# Define Convention

## Overview

This skill helps contributors define and categorise new conventions for the repository. It guides you through determining whether a convention belongs as an on-demand skill (`docs/skills/`) or an always-on steering/instructions file (`docs/conventions/`), then produces the correct file structure.

## Decision Criteria

Use these rules to classify a new convention:

| Criterion | Skill (`docs/skills/`) | Steering/Instructions (`docs/conventions/`) |
|-----------|------------------------|---------------------------------------------|
| Activation | Task-specific, triggered by a specific action | Always-on, applies to every interaction |
| Example triggers | "when creating commits", "when opening a PR", "when naming branches" | "always during code review", "in all responses", "whenever writing code" |
| Context impact | Loaded on-demand — keeps agent context lean | Always present in agent context |
| Format | `SKILL.md` with YAML frontmatter | Plain markdown file |

**Rule of thumb:** If the convention only matters during a specific task or action, make it a skill. If it applies universally regardless of what the agent is doing, make it a steering/instructions file.

## Questioning Workflow

When defining a new convention, gather the following information:

1. **Scope** — What area does this convention cover? (e.g., testing, code style, documentation, git operations)
2. **Trigger conditions** — When should the agent apply this convention? Is it tied to a specific action or always active?
3. **Audience** — Who does this convention apply to? (e.g., all contributors, frontend team, CI pipelines)
4. **Correct behaviour examples** — What does following this convention look like in practice?
5. **Incorrect behaviour examples** — What are common mistakes or anti-patterns this convention prevents?

## Output Templates

### Skill template (`docs/skills/<name>/SKILL.md`)

```markdown
---
name: <kebab-case-name>
description: Use when <trigger context>.
---
# <Convention Title>

## Format

<!-- Define the expected format or structure, if applicable -->

## Rules

<!-- List rules as bold key + explanation pairs -->

## Examples

<!-- Show correct usage examples in a code block -->

## Agent Behaviour

When <trigger context>:

1. **<First step>** — describe what the agent does
2. **<Next step>** — describe what the agent does
<!-- Continue as needed -->
```

### Steering/instructions template (`docs/conventions/<name>.md`)

```markdown
# <Convention Title>

## Purpose

<!-- Why this convention exists and what it prevents -->

## Rules

<!-- List rules that apply to every interaction -->

## Examples

### Correct

<!-- Show correct behaviour -->

### Incorrect

<!-- Show what to avoid -->
```

## Agent Behaviour

When defining a new convention:

1. **Ask clarifying questions** — determine scope, intended audience, and what problem the convention solves.
2. **Identify the trigger or context** — ask when this convention applies (e.g., "when creating commits", "when writing tests", "always during code review").
3. **Determine classification** — based on the trigger, classify as skill (task-specific) or steering/instructions (always-on). Explain the reasoning.
4. **Guide through file creation** — use the appropriate output template and walk through each section.
5. **Request examples** — ask for concrete examples of correct and incorrect behaviour to include in the convention.
6. **Present a draft** — show the complete file content for review.
7. **Confirm before finalising** — do not write the file until the contributor approves the draft.
