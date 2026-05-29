---
name: version-bump
description: Use when performing version bumps, releasing, or creating version/release PRs.
---
# Version Bump Convention

## Overview

Use the `version_bump` shell function (from the zsh dev plugin collection) to bump a project's version, then create a PR using the script's output.

## Workflow

### 1. Determine bump type

Ask the user which bump type to use:

- **patch** — bug fixes, small changes
- **minor** — new features, non-breaking changes
- **major** — breaking changes

If context suggests a type (e.g., only dependency updates → patch), suggest it but still confirm.

### 2. Run the script

Determine the working directory:
- If a `node-app/` directory exists at the repo root (web servers), run from there
- Otherwise, run from the repo root

```shell
cd node-app  # only if node-app/ exists
base_version_bump <patch|minor|major>
```

This will:
1. Checkout `main` and pull latest
2. Run `npm version --no-git-tag-version <type>`
3. Create branch `<type>/v<newVersion>`
4. Stage and commit as `v<newVersion>`

### 3. Push the branch

```shell
git push -u origin <type>/v<newVersion>
```

### 4. Create the PR

Use the script's output to create the PR:

- **Title:** `v<newVersion>`
- **Body:** Use the notes from the script output verbatim:

```markdown
### Notes
- <type> version bump: `<oldVersion>` → `<newVersion>`
- Compare: <comparison_url>
```

- **Base branch:** `main`
- **Head branch:** `<type>/v<newVersion>`
- **Assignee:** the current user
- **Labels:** add relevant labels (e.g., `release`, `version-bump`) if they exist in the repo

## Agent Behaviour

1. **Ask for bump type** before running anything — suggest one if context is clear
2. **Run `base_version_bump`** (not the interactive `version_bump` which requires stdin confirmation)
3. **Capture the output** — extract the version numbers and comparison URL
4. **Push the branch** and create the PR using the extracted output as the PR body
5. **Do not modify the PR body format** — use the script output text as-is
