---
name: handoff
description: Compact the current conversation into a handoff document so another agent or session can continue the work. Use when switching directories, passing to a separate Kiro CLI agent, or ending a session that will be resumed later.
---

# Handoff

Produce a self-contained handoff document summarising the current session so a fresh agent can continue the work without losing context.

## When to Use

- Task requires execution in a different working directory
- Handing off to a separate Kiro CLI agent (per task-routing rules)
- Session is getting long and context is at risk of being lost
- Work needs to continue in Kiro IDE after research/planning in CLI
- User explicitly asks for a handoff

## Rules

- The document must be self-contained — no external context needed to understand it
- Include all discovered information: file paths, API endpoints, ticket keys, relevant code snippets
- Reference existing artifacts (specs, PRDs, commits, PRs) by path or URL — don't duplicate their content
- Redact sensitive information (API keys, tokens, passwords)
- Include exact commands or scripts needed for the next session
- Specify the working directory the receiving agent should operate from
- Include a verification section: how to confirm the work is done

## Output Format

Save to `/tmp/handoff-[brief-topic].md` and display the path.

```markdown
## Handoff: [Brief Title]

### Context
[1-3 sentences: what we were doing and why]

### Current State
- What's done: [completed items]
- What's next: [remaining work]
- Blockers: [if any]

### Key Information
[All discovered details the next agent needs: file paths, ticket keys, environment details, code patterns found]

### Steps for Next Session
1. [Exact step with commands/paths]
2. ...

### Working Directory
`/path/to/repo`

### Verification
[How to confirm the work is complete]

### Suggested Skills
[Which skills the next agent should invoke: e.g., diagnosing-bugs, codebase-design, tdd]

### Constraints
[What NOT to do]
```

## Behaviour

1. Review the conversation to identify: goal, progress, discoveries, remaining work
2. Compress — remove false starts, redundant exploration, and resolved tangents
3. Preserve — keep all facts, file paths, commands, and decisions
4. Structure — write in the format above
5. Save to temp directory
6. Tell the user the file path and how to use it in the next session
