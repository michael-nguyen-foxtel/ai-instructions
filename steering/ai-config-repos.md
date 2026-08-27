# AI Config Repos

Two repositories hold the AI workflow configuration. They look similar but serve different audiences and must not be blindly synced.

## The Two Repos

| Repo | Role | Audience | Machine/tracker-specific? |
|------|------|----------|---------------------------|
| **ai-instructions** | This machine's source of truth. `setup.sh` deploys it to `~/.kiro/skills` and `~/.kiro/steering`. | Private (me) | Yes — Jira, company deploys, hardcoded `/Users/nguyenm` paths, product steering |
| **ai-workflow-skills** | Public "journey through agentic/loop engineering" repo. Shared with friends/ex-colleagues. | Public | No — tracker-agnostic, no company specifics, MIT-licensed |

Local paths:
- `/Users/nguyenm/Documents/SourceCode/ai-instructions`
- `/Users/nguyenm/Documents/SourceCode/ai-workflow-skills`

## What Lives Where

**ai-instructions only** (never flows to public):
- Product steering: `product-hubbl.md`, `product-watchafl-watchnrl.md`, `github-repos.md`, `testing-conventions.md`
- Company deploy skills: `deploy-fiso`, `deploy-coupler`, `environment-check`, `release-email`, `release-notes*`
- Hardcoded machine paths (`/Users/nguyenm/...`) — an intentional convention here
- Jira-specific phrasing in `to-tickets`, `to-spec` (cloudId, WEB project, Blocks link type)

**Both repos** (the generic workflow core):
- The main-flow skills (grilling, to-spec, to-tickets, implement-from-spec, code-review, pull-requests, commit-messages)
- Shaping, upkeep, reference, productivity skills
- Steering: `task-routing`, `context-management`, `token-efficiency`, `kiro-crew`

**ai-workflow-skills only:**
- `LICENSE`
- Tracker-agnostic phrasing ("whatever tracker the project uses" instead of Jira)

## Sync Rules

The repos are NOT mirror copies. When syncing a genuine improvement:

1. **Identify the direction.** Live `~/.kiro` changes flow *back* into ai-instructions (it's the source of truth, so live edits are undercommitted until captured here).
2. **Genericise for public.** Anything reusable flows to ai-workflow-skills *with company/tracker/tool specifics stripped or turned into examples*. A specific tool (Herdr, Jira, FISO) becomes "example: X" or a pattern, never a hard dependency.
3. **Never overwrite deliberate differences.** Product steering, deploy skills, and Jira phrasing stay private. Tracker-agnostic phrasing stays public.
4. **PR flow for both.** These are personal repos but ai-workflow-skills is public — branch, commit (signed, via shell), PR. Never commit direct to main.

## Deployment

`ai-instructions/setup.sh` copies `steering/*.md` wholesale (no manifest — dropping a new `.md` in `steering/` is enough) and copies skills by the `SKILL_CATEGORIES` map (new skills must be added to that map). `~/.kiro` is a deployment *target*, so its live state should always be reproducible from ai-instructions.
