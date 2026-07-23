---
name: version-bump
description: Use when performing version bumps, releasing, or creating version/release PRs.
disable-model-invocation: true
---
# Version Bump

Bump a project's version and create a PR.

## Workflow

### 1. Determine bump type

Ask which bump type:

- **patch** — bug fixes, small changes
- **minor** — new features, non-breaking changes
- **major** — breaking changes

If context suggests a type (e.g., only dependency updates → patch), suggest it but confirm.

### 2. Detect package manager and working directory

| Lockfile | Package manager |
|----------|----------------|
| `package-lock.json` | npm |
| `pnpm-lock.yaml` | pnpm |

Working directory:
- If `node-app/` exists at repo root → run npm commands from there
- Otherwise → repo root

### 3. Bump the version

Run these steps directly (do NOT rely on `base_version_bump` — it's a user shell function unavailable in this environment):

```shell
# 1. Checkout main and pull latest
git checkout main
git pull

# 2. Read current version
OLD_VERSION=$(node -p "require('./package.json').version")

# 3. Bump version (no git tag)
npm version <patch|minor|major> --no-git-tag-version
NEW_VERSION=$(node -p "require('./package.json').version")

# 4. Create and switch to branch
git checkout -b <type>/v<NEW_VERSION>

# 5. Update lockfile
# npm repos:
npm install --package-lock-only
# pnpm repos:
pnpm install --lockfile-only

# 6. If npm version generated a package-lock.json in a pnpm repo, delete it

# 7. Stage and commit
git add package.json package-lock.json  # (or pnpm-lock.yaml)
git commit -m "v<NEW_VERSION>"
```

**Critical:** Step 4 must use `git checkout -b` (create AND switch) — do NOT use a create-only operation that leaves you on main.

### 4. Push and create PR

```shell
git push -u origin <type>/v<NEW_VERSION>
```

Create the PR using `gh` CLI (handles multiline body correctly):

```shell
gh pr create \
  --base main \
  --title "v<NEW_VERSION>" \
  --body "### Notes
- <type> version bump: \`<OLD_VERSION>\` → \`<NEW_VERSION>\`
- Compare: https://github.com/<org>/<repo>/compare/v<OLD_VERSION>...<type>/v<NEW_VERSION>"
```

**Do NOT use the GitHub MCP `create_pull_request` tool** — it mangles newlines in the body field (renders literal `\n`). Use `gh pr create` via shell instead.

### 5. Post-merge (release procedure)

After the PR is merged, provide the user with Jira release details then remind them of the remaining manual steps.

#### 5a. Jira release prep (agent provides)

The agent cannot create Jira versions (no MCP tool available). Instead, provide:

1. **Release title:** `<Capitalised Spaced Repo Name> <version>`
   - `hawk-web-server` → `Hawk Web Server 7.6.0`
   - `hawk-widgets` → `Hawk Widgets 4.2.0`
   - `magneto-widgets` → `Magneto Widgets 3.5.0`
   - `magneto-web-server` → `Magneto Web Server 2.3.0`
   - `fiso-server` → `FISO Server 7.1.0`

2. **Tickets to tag:** Find commits between the previous version tag and the new one, extract WEB-XXXX keys from commit messages/PR titles. List them for the user.

3. **Description:** A concise summary of the work included in this release.
   - Multi-feature releases: pipe-separated keywords (e.g., `Remove OTP | Maintenance Page`)
   - Single-theme releases: one sentence (e.g., `Migrated application logging to CloudWatch Agent for compatibility with the updated Amazon Linux 2023 platform.`)

#### 5b. Create WRT tracking ticket (agent does this)

Create a task in the WRT (Web Release Tracking) project:

| Field | Key | Value |
|-------|-----|-------|
| Summary | `summary` | `<Release Title>` (same as 5a.1) |
| Description | `description` | Same concise summary as 5a.3 |
| Project dropdown | `customfield_20657` | See mapping below |
| WEB release URL | `customfield_20653` | `https://livesport.atlassian.net/projects/WEB/versions/<ID>/tab/release-report-all-issues` |
| Assignee | `assignee` | `5fd01cdf4d2179006e9a0270` (Michael Nguyen) |

**Project dropdown mapping (customfield_20657):**

| Repo | Value | ID |
|------|-------|----|
| hawk-web-server | Hawk Web Server | 28075 |
| hawk-widgets | Hawk Widgets | 28074 |
| magneto-widgets | Magneto Widgets | 28076 |
| magneto-web-server | Magneto Web Server | 28077 |

Leave the release checklist (`customfield_20652`) empty — user ticks these off as steps complete.

The WEB release URL requires the Jira version ID. Ask the user for it (they'll have just created the version), or parse it from the URL they provide.

#### 5c. Remaining manual steps

1. **User** creates the Jira release version with the provided title, description, and tags tickets
2. QA regression on staging
3. Prepare release comms (use `/release-email` skill)
4. Deploy to production (FTP for widgets, GitHub Actions for web servers)
5. Airtable release notes entry

## Agent Behaviour

1. Ask for bump type before running anything
2. Detect package manager by checking lockfiles
3. Determine working directory (`node-app/` vs root)
4. Run the steps inline (never call `base_version_bump` or `version_bump`)
5. Use `git checkout -b` to create AND switch to the branch in one step
6. Update lockfile, stage everything, commit as `v<NEW_VERSION>`
7. Push the branch
8. Create PR via `gh pr create` (not the GitHub MCP tool)
9. After merge: provide Jira release title, ticket list, and description summary
10. Create WRT tracking ticket with release URL
11. Remind the user of remaining manual steps (create version, QA, comms, deploy)
