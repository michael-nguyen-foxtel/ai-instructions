# Herdr

Herdr is the terminal orchestration layer. All kiro-cli sessions run inside Herdr-managed panes. It provides workspace management, agent lifecycle, worktree integration, and status visibility.

## Role

Herdr is the process manager and multiplexer. It replaces manual worktree setup, manual session spawning, and copy-paste handoffs between sessions. The orchestrator session uses Herdr's CLI to spawn sibling agents directly — no scripts, no handoff docs for parallel work.

## Key Commands

### Worktree lifecycle (replaces manual `git worktree add`)

```bash
# Create worktree + workspace in one shot
herdr worktree create --cwd <repo-root> --branch <branch-name> --label "<label>" --no-focus

# Clean up after merge
herdr worktree remove --workspace <workspace_id> --force
```

### Agent lifecycle

```bash
# Start kiro-cli in a pane
herdr agent start "<name>" --kind kiro --pane <pane_id>

# Send initial prompt (the automated handoff)
herdr agent prompt "<name>" "<prompt text>"

# Wait for agent to finish or need input
herdr agent wait "<name>" --until idle --until blocked

# Check what an agent is showing
herdr agent read "<name>" --source visible
```

### Pane operations

```bash
# Run a command in a pane (e.g. install deps)
herdr pane run <pane_id> "pnpm install"

# Wait for output (e.g. install finished)
herdr pane wait-output <pane_id> --match "Done" --timeout 120000

# Read pane output
herdr pane read <pane_id> --source recent-unwrapped --lines 20
```

### Status

Agent states visible in Herdr menu:
- `idle` — ready for input (tab has been seen)
- `working` — processing
- `blocked` — needs approval or input from you
- `done` — finished (tab not yet seen)
- `unknown` — agent present but state unclear

## Orchestration Pattern

When the orchestrator creates parallel tickets:

1. `herdr worktree create` for each independent ticket (creates workspace + pane)
2. `herdr pane run` to install dependencies
3. `herdr pane wait-output` to confirm install finished
4. Write scoped spec into the worktree
5. `herdr agent start` to activate kiro-cli in the pane
6. `herdr agent prompt` to send the implement command

No scripts, no copy-paste, no handoff docs for parallel implementation. The orchestrator does it all via Herdr's CLI.

## Rules

- **Worktrees through Herdr** — use `herdr worktree create` instead of raw `git worktree add`. Herdr tracks the workspace-to-worktree relationship.
- **Agent names must match** `[a-z][a-z0-9_-]{0,31}` — use ticket IDs as lowercase slugs (e.g., `web-4601-props`).
- **`--no-focus` by default** when spawning — don't steal focus from the orchestrator.
- **Check agent state before prompting** — `blocked` means it's waiting for you, don't send a new prompt on top of it.
- **Cleanup after merge** — `herdr worktree remove` handles both git worktree and Herdr workspace.

## Integration with Skills

| Skill | Herdr replaces |
|-------|---------------|
| `/to-tickets` (worktree setup) | Manual `git worktree add` + `cd` + `pnpm install` |
| `/to-tickets` (launch prompts) | Copy-paste handoff docs into new sessions |
| `/implement-from-spec` (parallel) | Separate terminal windows or tmux panes |
| Stacked PRs (wave merge) | Manual branch switching between worktrees |
| Stacked PRs (wave merge) | Manual branch switching between worktrees |

## Constraints

- Agent startup has a default 30s timeout — large projects needing MCP server init may need explicit `--timeout`
- `agent prompt` on a `blocked` agent returns `agent_blocked` — check state first
- One controller per terminal — `--takeover` required to steal control from another attach
- Herdr manages the kiro-cli process — don't `kill` agents manually, use workspace close or worktree remove
