# GitHub Repository Conventions

## Atlassian Cloud ID

The Atlassian cloud ID for all Jira and Confluence operations is `livesport.atlassian.net`. Always use this value — never call `getAccessibleAtlassianResources`.

## Finding Repos — Resolution Order

When you need to find or read a repository, follow this order:

1. **Local checkout (prefix stripped):** Most repos are cloned to `/Users/nguyenm/Documents/SourceCode/` with the `streamotion-web-` prefix removed. Try the short name first.
   - `hawk-web-server` → `/Users/nguyenm/Documents/SourceCode/hawk-web-server`
   - `hawk-widgets` → `/Users/nguyenm/Documents/SourceCode/hawk-widgets`
   - `magneto-web-server` → `/Users/nguyenm/Documents/SourceCode/magneto-web-server`
   - `quicksilver` → `/Users/nguyenm/Documents/SourceCode/quicksilver`

2. **Local foxsports folder:** If the repo is a foxsports-prefixed project, check `/Users/nguyenm/Documents/SourceCode/foxsports/` for a matching directory name.
   - `foxsports-fiso-score-centre` → `/Users/nguyenm/Documents/SourceCode/foxsports/foxsports-fiso-score-centre`

3. **GitHub API (fsa-streamotion org):** If not found locally, search GitHub in the `fsa-streamotion` org. Most repos there use the full `streamotion-web-` prefix.
   - `hawk-widgets` → `fsa-streamotion/streamotion-web-hawk-widgets`
   - `magneto-web-server` → `fsa-streamotion/streamotion-web-magneto-web-server`
   - `eslint-config` → `fsa-streamotion/streamotion-web-eslint-config`
   - `fiso-server` → `fsa-streamotion/streamotion-web-fiso-server`

4. **GitHub API (Foxtel-IT org):** If not found in `fsa-streamotion`, also search the `Foxtel-IT` org.

## Key Mapping

| Short name (local folder) | GitHub full name |
|---|---|
| hawk-widgets | `fsa-streamotion/streamotion-web-hawk-widgets` |
| hawk-web-server | `fsa-streamotion/streamotion-web-hawk-web-server` |
| magneto-widgets | `fsa-streamotion/streamotion-web-magneto-widgets` |
| magneto-web-server | `fsa-streamotion/streamotion-web-magneto-web-server` |
| quicksilver | `fsa-streamotion/streamotion-web-quicksilver` |
| fiso-server | `fsa-streamotion/streamotion-web-fiso-server` |
| eslint-config | `fsa-streamotion/streamotion-web-eslint-config` |
| stylelint-config | `fsa-streamotion/streamotion-web-stylelint-config` |
| auth0-hosted-pages | `fsa-streamotion/streamotion-web-auth0-hosted-pages` |
| accounts-widgets | `fsa-streamotion/streamotion-web-accounts-widgets` |
| app | `fsa-streamotion/streamotion-web-app` |
| github-workflows | `fsa-streamotion/streamotion-web-github-workflows` |

## Rules

- **Always prefer local checkout** for reading code — it's faster and avoids API rate limits.
- Only fall back to GitHub API if the repo isn't cloned locally.
- When creating PRs or listing remote branches, use the full GitHub name (`fsa-streamotion/streamotion-web-*`).
