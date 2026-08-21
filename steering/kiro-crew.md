# Kiro Crew

Kiro Crew is the asynchronous, autonomous layer that complements Kiro CLI. It runs as a local desktop app with its own memory, knowledge, and app ecosystem. The two systems do not share skills, steering, or configuration — they serve different purposes.

## Routing

| Signal | Route to |
|--------|----------|
| Code implementation (features, fixes, refactors) | **Kiro CLI** |
| Deploys (FISO, EB, QA builds) | **Kiro CLI** |
| AWS operations, S3, filesystem, data tasks | **Kiro CLI** |
| Jira/Confluence access | **Kiro CLI** (has Atlassian MCP tools) |
| Git operations, PRs, commits | **Kiro CLI** |
| Spec → tickets → implement pipeline | **Kiro CLI** |
| PR review with persistent per-repo learning | **Kiro Crew** (Code Review Sage) |
| Multi-cycle background research | **Kiro Crew** (Research Lab) |
| Ops incident auto-response / alarm watching | **Kiro Crew** (Ops Mission Control) |
| GitHub issue triage across repos | **Kiro Crew** (Issue Radar) |
| Periodic background checks (heartbeat tasks) | **Kiro Crew** |
| Autonomous performance improvement cycles | **Kiro Crew** (Auto-Improvement) |

## Shared infrastructure

Kiro Crew reads from the same `~/.kiro/` directory as Kiro CLI:
- **Steering docs** (`~/.kiro/steering/`) — shared. Both systems load the same conventions.
- **Skills** (`~/.kiro/skills/`) — shared. Crew agents can invoke grilling, to-spec, research, etc.
- **Agent templates** — shared. The `pr-reviewer`, `researcher`, `test-writer` crews use your definitions.

This means Crew agents already know your conventions, product context, and workflow patterns.

## What Kiro Crew cannot do

- Access your AWS profiles or S3 buckets (no AWS CLI access)
- Bulk-ingest Confluence pages or documents (knowledge builds organically through conversations)
- Merge PRs or push code (it stages draft reviews — you submit)
- Access Jira/Confluence directly (no Atlassian MCP connection)
- Write to your local filesystem outside its workspace (sandboxed)
- Read files from ~/Documents/SourceCode/ or any path outside ~/.kiro/crew/workspace/

## Scheduled jobs & heartbeat constraints

Scheduled jobs and heartbeat tasks can only use tools available to Crew:
- `gh` CLI (GitHub PRs, issues, CI status, repo search) ✓
- Web browsing ✓
- Crew's own memory and knowledge store ✓

They CANNOT use:
- Jira/Confluence (no Atlassian MCP)
- AWS CLI
- Local filesystem reads
- Any tool requiring your terminal session

Keep scheduled prompts scoped to GitHub-accessible data. For Jira summaries or AWS health checks, use Kiro CLI instead.

## Apps to enable

These are the high-value apps based on our workflow:

| App | Why | Enable with |
|-----|-----|-------------|
| **Code Review Sage** | Learns from our repos' merged PRs, reviews weighted by blast radius | `kirocrew app enable code-review-sage` |
| **Research Lab** | AFK multi-cycle research campaigns (replaces single-shot `/research` for big questions) | `kirocrew app enable auto-research` |
| **Issue Radar** | Surfaces which GitHub issues/PRs need attention first | `kirocrew app enable issue-radar` |

### Not yet (enable when needed)

| App | When to enable |
|-----|----------------|
| Ops Mission Control | When CloudWatch alarms are wired up for Hawk/Hubbl EB environments |
| Auto-Improvement | When we have a repo with a measurable performance metric to optimise |
| Channels (Slack) | When we want ops threads or research findings surfaced to Slack |

## Code Review Sage — how it learns

1. It does NOT bulk-ingest old PRs
2. It learns incrementally: when reviewing a fix-type PR, it traces back to the introducing commit and learns what class of defect was missed
3. You can seed conventions manually at: `~/.kiro/crew/apps/code-review-sage/data/learnings/common/learned-patterns.md`
4. Per-repo patterns go in: `~/.kiro/crew/apps/code-review-sage/data/learnings/repos/`
5. Candidate patterns stage in a `.candidate.md` file — a human triggers consolidation into the live ruleset

## Heartbeat tasks

Drop one-line tasks in `~/.kiro/crew/workspace/HEARTBEAT.md` — Kiro Crew picks them up on the next cycle. Good for:

- "Check if FISO staging is serving the expected widget version"
- "Are there any stale PRs in hawk-widgets older than 2 weeks?"
- "Summarise what changed in the WEB Jira project this week"

## Knowledge & Memory

- **Memory** (`memory.db`): semantic + episodic memory from conversations. Builds up over time. Currently empty — will accumulate as you chat with Kiro Crew.
- **Knowledge** (`knowledge.db`): vector store for reference material. Ingested through the Kiro Crew chat interface, not a CLI bulk import.
- **Learn** (`kirocrew learn add`): stores short correction strings (e.g., "use snake_case for variables"). Not for document ingestion.

## Integration seams

The two systems connect at these points:

1. **Wayfinder research tickets** → fire a Kiro Crew Research Lab campaign instead of a CLI `/research` subagent for deep, multi-cycle questions
2. **Code Review Sage** → review PRs through Kiro Crew, then use findings when writing the PR description or addressing feedback in Kiro CLI
3. **Issue Radar** → triage in Kiro Crew, implement in Kiro CLI
4. **Heartbeat → Kiro CLI** — if a heartbeat task surfaces something actionable, pick it up in a CLI session

## Data locations

| What | Path |
|------|------|
| Kiro Crew home | `~/.kiro/crew/` |
| Config | `~/.kiro/crew/config.json` |
| Memory DB | `~/.kiro/crew/memory.db` |
| Knowledge DB | `~/.kiro/crew/workspace/knowledge/knowledge.db` |
| Heartbeat tasks | `~/.kiro/crew/workspace/HEARTBEAT.md` |
| Code Review Sage data | `~/.kiro/crew/apps/code-review-sage/data/` |
| Learned patterns | `~/.kiro/crew/apps/code-review-sage/data/learnings/common/learned-patterns.md` |
