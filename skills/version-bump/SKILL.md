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
5. Print a comparison URL: `https://github.com/<org>/<repo>/compare/v<oldVersion>...<type>/v<newVersion>`

Capture the old version, new version, and comparison URL from the output.

### 4. Post-version lockfile update

After the script completes, update the lockfile:

- **npm repos:** `npm install --package-lock-only`
- **pnpm repos:** `pnpm install --lockfile-only`

If `npm version` generates a `package-lock.json` in a pnpm repo (where none existed), delete it before committing. Amend the version commit if needed.

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

### 6. Post-merge (release procedure)

After the PR is merged, the broader release procedure is manual:
1. Create a **Jira release version** and tag tickets with the `fixVersion`
2. QA regression on staging
3. Prepare release comms (use `/release-email` skill)
4. Deploy to production (FTP for widgets, GitHub Actions for web servers)
5. Airtable release notes entry
6. Update Slack #sm-web-qa deployed versions

## Agent Behaviour

1. Ask for bump type before running anything
2. Detect package manager by checking lockfiles
3. Determine working directory (`node-app/` vs root)
4. Run `base_version_bump` (not the interactive `version_bump`)
5. Capture old version, new version, and comparison URL from output
6. Run the correct lockfile update
7. Remove unwanted lockfiles (package-lock.json appearing in pnpm repos)
8. Amend the version commit if lockfile changes were needed
9. Push the branch and create the PR with comparison URL in body
10. Remind the user of post-merge steps (Jira release, QA, comms, deploy)
