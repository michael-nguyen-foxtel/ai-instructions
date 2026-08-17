# Implement

Read the spec and implement it methodically. Plan first, then build test-first.

## Process

1. **Read the spec** — understand what's being built and the decisions already made
2. **Explore the codebase** — find existing patterns, seams, and conventions to match
3. **Plan the approach** — list the changes needed (modules, interfaces, tests). Present to the user for confirmation.
4. **Implement test-first** for each change:
   - Write a failing test that encodes the expected behaviour
   - Write the minimal code to pass it
   - Refactor if needed
   - Verify: lint, typecheck, test
5. **Verify the full build** before presenting as done

## Rules

- Match the project's existing patterns (style, naming, architecture)
- Don't add features beyond what the spec asks for
- Don't introduce new dependencies without asking
- Don't refactor unrelated code
- If something in the spec doesn't make sense given the code, ask before proceeding
- Commit via shell: `git commit -m "message"`
- Push to a feature branch, never to main

## Verification

After implementation:
- All new tests pass
- All existing tests still pass
- Lint and typecheck clean
- Build succeeds

If verification fails, fix it. After 2 failed fix attempts, stop and explain what's wrong.

## Output

```
✓ Implementation complete
Changes: [list of files]
Tests: [X passing, Y new]
Branch: [branch-name]
Ready for: PR creation
```
