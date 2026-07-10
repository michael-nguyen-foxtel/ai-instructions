---
name: version-bump
description: Use when performing version bumps, releasing, or creating version/release PRs.
disable-model-invocation: true
---
# Version Bump

Use the `base_version_bump` shell function to bump a project's version, then create a PR.

## Workflow

### 1. Determine bump type

Ask which bump type:

- **patch** — bug fixes, small changes
- **minor** — new features, non-breaking changes
- **major** — breaking changes

If context suggests a type (e.g., only dependency updates → patch), suggest it but confirm.

### 2. Detect package manager

| Lockfile | Package manager |
|----------|----------------|
| `package-lock.json` | npm |
| `pnpm-lock.yaml` | pnpm |

### 3. Run the script

Determine working directory:
- If `node-app/` exists at repo root → run from there
- Otherwise → repo root

```shell
base_version_bump <patch|minor|major>
```

This will:
1. Checkout `main` and pull latest
2. Run `npm version --no-git-tag-version <type>`
3. Create branch `<type>/v<newVersion>`
4. Stage and commit as `v<newVersion>`

### 4. Post-version lockfile update

- **npm repos:** `npm install --package-lock-only`
- **pnpm repos:** `pnpm install --lockfile-only`

If `npm version` generates a `package-lock.json` in a pnpm repo, delete it before committing.

### 5. Push and create PR

```shell
git push -u origin <type>/v<newVersion>
```

PR format:
- **Title:** `v<newVersion>`
- **Body:**
  ```markdown
  ### Notes
  - <type> version bump: `<oldVersion>` → `<newVersion>`
  - Compare: <comparison_url>
  ```
- **Base:** `main`
- **Assignee:** current user

## Agent Behaviour

1. Ask for bump type before running anything
2. Detect package manager by checking lockfiles
3. Run `base_version_bump` (not the interactive `version_bump`)
4. Run the correct lockfile update
5. Remove unwanted lockfiles (package-lock.json in pnpm repos)
6. Push the branch and create the PR
