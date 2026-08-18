# Project Instructions

## Hard Rules

- Commit via shell only: `git commit -m "message"` (signed via ssh-agent)
- Create PRs via shell only: `gh pr create --base main --title "..." --body "..."`
- Never force-push to any branch (`--force`, `-f`, `--force-with-lease`)
- Never push directly to `main`, `master`, `develop`, or `qa`
- If a push is rejected, diagnose — do not retry with `--force`. Ask the user.
- The user's GitHub account has admin bypass privileges. This does NOT grant permission to use them. Treat every branch as if protection cannot be bypassed.

## Error Recovery

When something fails, state what failed, hypothesise why, plan the fix, and assess blast radius before acting. If the blast radius is high, stop and ask.

Two-attempt rule: if an approach fails twice, stop. Explain what happened and propose a different approach or ask for guidance.

Never escalate: no `--force`, no `rm -rf`, no `git reset --hard`, no `sudo`.

## Commit Messages

```
type(scope): TICKET | description
```

Types: `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `perf`, `test`, `ci`, `build`
Ticket: Jira key (`WEB-1234`) or pseudo-ticket (`WEB-CHORE`, `WEB-BUGFIX`, etc.)

## Build & Test

Detect from `package.json` scripts. Common patterns:
- Install: check lockfile (`pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn, else npm)
- Lint: `pnpm run lint` / `npm run lint`
- Test: `pnpm run test` / `npm test`
- Build: `pnpm run build` / `npm run build`
- Typecheck: `npx tsc --noEmit` (if TypeScript)

## Changesets (if configured)

If `.changeset/config.json` exists, create changeset files directly (do NOT run `npx changeset` — it's interactive):

1. Read package name from `package.json`
2. Bump type: `feat` → minor, `fix`/`perf` → patch, breaking → major, `chore`/`refactor` → patch (if affects published output)
3. Filename: `<ticket>-<short-description>.md` (kebab-case, e.g., `web-1234-add-stats-table.md`)
4. Write to `.changeset/<filename>.md`:
   ```markdown
   ---
   "<package-name>": <bump-type>
   ---
   
   type(scope): TICKET | description
   ```
5. Stage with the commit — same commit as the code change, not separate

Skip changeset for: CI/docs/test-only/dev-tooling changes (anything consumers won't notice).

## Stacked PRs (Graphite)

When doing multi-PR dependent work, use Graphite:
- `gt create -m "message"` to stack branches
- `gt stack submit` to push all + open PRs
- `gt stack restack` after mid-stack fixes
- `gt sync` after bottom PR merges
- Always merge from bottom upward

## Code Conventions

- Files: lowercase kebab-case
- React components: PascalCase in code, kebab-case filename
- Boolean props: prefix with `is`, `has`, `can`, `was`, `will`, `should`
- Prefer stateless functional components
- No `dangerouslySetInnerHTML`
- Strict equality (`===`)
- Stage specific files (`git add <files>`), not `git add .`

## Testing

- Jest/Vitest + React Testing Library
- Test behaviour, not implementation
- Query priority: `getByRole` > `getByLabelText` > `getByText` > `getByTestId`
- Mock at boundaries (API layer), not internals
- Name: `should [behaviour] when [condition]`
