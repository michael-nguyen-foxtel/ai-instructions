# Spec

Synthesise the current conversation into a written spec. Don't interview me again — just distil what we've already discussed.

## Process

1. Read back through the conversation for decisions, constraints, and requirements
2. Write the spec using the template below
3. Save it to `.kiro/specs/<TICKET>-SPEC.md` (or a descriptive slug if no ticket exists)
4. If anything is unclear or missing, note it in the spec rather than guessing

## Template

```markdown
## Problem Statement

The problem from the user's perspective.

## Solution

The solution from the user's perspective.

## User Stories

1. As a <actor>, I want <feature>, so that <benefit>

Cover edge cases, not just the happy path.

## Implementation Decisions

Decisions made during discussion:
- Architectural choices
- Interfaces and contracts
- Schema changes
- Specific interactions and flows

Do NOT include file paths or code snippets — they go stale.

## Testing Decisions

- What makes a good test for this feature
- Which seams to test at
- Any existing test patterns to follow

## Out of Scope

Things explicitly excluded.

## Open Questions

Anything still unresolved (if any).
```

## Rules

- Use the project's domain vocabulary
- Keep implementation decisions at the interface/contract level
- If you lack context for a section, say what's missing rather than guessing
