---
name: version-bump
description: Use when performing version bumps, releasing, or creating version/release PRs.
disable-model-invocation: true
---
# Version Bump

Bump a project's version and create a PR.

## Detecting the flow

Check which versioning strategy the repo uses:

1. If `.changeset/config.json` exists → use **Changesets flow**
2. Otherwise → use **Manual flow**

## Detecting the package manager

| Lockfile | Package manager | Run command |
|----------|----------------|-------------|
| `pnpm-lock.yaml` | pnpm | `pnpm` |
| `yarn.lock` | yarn | `yarn` |
| `package-lock.json` | npm | `npm` |
| None | npm | `npx` |

---

## Changesets Flow

When the repo has `.changeset/config.json`:

### Adding a changeset (during development)

Run `npx changeset` (interactive, works regardless of package manager) or create a file manually:

`.changeset/<descriptive-name>.md`:
```markdown
---
"@fsa-streamotion/package-name": patch
---

Brief description of the change
```

### Bump levels

- `patch` — internal refactor, no API change (TS migration, dep update, bug fix)
- `minor` — new exported types, components, or features
- `major` — breaking change to existing exports

### When to add a changeset

- Every PR that changes runtime code (src/, lib/, components/)
- Every PR that changes the package's public API (new exports, changed types)
- Bug fixes that affect consumers

### When NOT to add a changeset

- CI/CD-only changes (workflow files, Docker config)
- Documentation-only changes
- Test-only changes
- Storybook-only changes
- Changes to dev tooling (eslint config, prettier, etc.)

### Release flow

1. PRs land on main with changeset files included in the commit
2. GitHub Action creates a "Version Packages" PR (bumps package.json version + writes CHANGELOG.md)
3. Merge the "Version Packages" PR when ready to release
4. Create a GitHub Release to trigger the publish workflow

### Agent behaviour (changesets)

1. When creating a PR, check if `.changeset/config.json` exists
2. If it does, check if the PR includes source code changes (not just CI/docs/tests)
3. If source changes exist and no `.changeset/*.md` file is staged, remind the user: "This PR changes source code but has no changeset. Run `npx changeset` to add one."
4. When a "Version Packages" PR is merged, follow the post-merge steps (Jira release, WRT ticket, etc.) from the Manual flow section below — the publish trigger is the same

---

## Manual Flow

When the repo does NOT have `.changeset/config.json`:

### 1. Determine bump type

Ask which bump type:

- **patch** — bug fixes, small changes
- **minor** — new features, non-breaking changes
- **major** — breaking changes

If context suggests a type (e.g., only dependency updates → patch), suggest it but confirm.

### 2. Detect working directory

- If `node-app/` exists at repo root → run commands from there
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
# yarn repos:
yarn install

# 6. If npm version generated a package-lock.json in a pnpm repo, delete it

# 7. Stage and commit
git add package.json package-lock.json  # (or pnpm-lock.yaml / yarn.lock)
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

1. Check for `.changeset/config.json` to determine the flow
2. If changesets: remind about changeset files during PRs, handle "Version Packages" PR merge
3. If manual: ask for bump type before running anything
4. Detect package manager by checking lockfiles
5. Determine working directory (`node-app/` vs root)
6. Run the steps inline (never call `base_version_bump` or `version_bump`)
7. Use `git checkout -b` to create AND switch to the branch in one step
8. Update lockfile, stage everything, commit as `v<NEW_VERSION>`
9. Push the branch
10. Create PR via `gh pr create` (not the GitHub MCP tool)
11. After merge: provide Jira release title, ticket list, and description summary
12. Create WRT tracking ticket with release URL
13. Remind the user of remaining manual steps (create version, QA, comms, deploy)
