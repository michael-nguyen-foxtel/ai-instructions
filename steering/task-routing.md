# Task Routing

When planning work for a ticket, determine the appropriate execution method:

| Execution Method | When to Use |
|-----------------|-------------|
| **Kiro (GitHub Copilot)** | Code changes in a repository (PRs, features, bug fixes) |
| **Kiro CLI (current agent)** | Local scripting, file manipulation, shell commands within the current working directory |
| **Kiro CLI (separate agent)** | Tasks requiring shell execution in a different directory, CMS uploads, image processing, API calls, or any work that doesn't involve code changes to a repo |

## Handover Prompt Rule

If the task requires execution that is **not a code change in a repository** AND **cannot be completed from the current working directory**, produce a **handover prompt** instead of attempting the work directly.

The handover prompt must be:
- Self-contained (no external context needed)
- Include all discovered information (team IDs, API endpoints, file paths, credentials locations)
- Include exact commands/scripts to run
- Specify the working directory the new agent should operate from
- Include verification steps

## Handover Prompt Format

```
## Task: [TICKET] — [Title]

[Brief context paragraph]

### Prerequisites
[Any installs or setup needed]

### Steps
[Numbered steps with exact commands/scripts]

### Verification
[How to confirm success]

### Constraints
[What NOT to do]
```

## Behaviour

1. Do the research and planning (fetch tickets, read docs, call APIs, explore code).
2. Determine the execution method early — don't attempt execution if a handover is more appropriate.
3. If producing a handover, tell the user explicitly: "This needs a separate Kiro CLI agent. Here's the handover prompt."
4. Do NOT waste turns attempting shell execution or file writes that will fail due to working directory constraints.
