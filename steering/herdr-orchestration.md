# Herdr Orchestration — When to Fan Out

Decision rule for spinning up parallel agent sessions via `herd-launch`. This governs a single question: **should this work become multiple Herdr sessions, or stay in one chat?**

Read this alongside `context-management.md` (the delegate/handoff/inline matrix) and `herdr.md` (the Herdr command surface). This doc adds the "real Herdr sessions" row to that existing framework — it does not replace it.

## The Core Principle

**Propose, never auto-fire.** An agent must NOT silently create workspaces. Recognise when fan-out would help, then offer it. The judgment to proceed stays with the user. Silent workspace creation is how a clean sidebar turns into clutter the user has to clean up.

The correct interaction is a suggestion:

> "This splits cleanly into three independent slices — tokens, routing, tests. Want me to spin them up as separate Herdr sessions with `herd-launch`, or keep it in one chat?"

Then wait for a yes.

## When Fan-Out Is Appropriate

Fan out only when **ALL** of these hold:

1. **Independent** — the pieces share no state and have no ordering dependency between them
2. **Substantial** — each piece is a real implementation slice, not a one-liner or a quick question
3. **Concurrency helps** — the user gains from them running at once while attention is elsewhere
4. **Two or more pieces** — a single piece is just work in the current chat

The tell: **if you cannot name the independent pieces before launching, it is too early to fan out.** Spinning up agents to "figure out the shape" fragments thinking instead of focusing it.

## When to Stay Inline (the default)

Keep the work in one chat when any of these are true:

- The task fits one session (the overwhelming majority of tasks)
- Pieces depend on each other (sequential → one chat or a stack, not parallel sessions)
- Scope is unclear or exploratory
- It is a quick fix, a question, or a single-file change

Default to inline. Fan-out is the exception that must justify itself against all four criteria above.

## What the Orchestrator Can and Cannot Do

Be honest about the boundary so suggestions do not over-promise:

- **Can**: plan the split, launch named sessions via `herd-launch`, send each an opening prompt, mix agent kinds (`--kind kiro|claude|codex|gemini|...`).
- **Cannot**: watch the child sessions' conversations live and respond to them. A chat is not a supervision loop. The launching agent is a *planner and launcher*, not a live supervisor.
- **The user supervises**, using Herdr's sidebar (`working` / `blocked` / `done`) to see which session needs them. That is the supervision layer — not the orchestrator.

If true unattended supervision is needed (poll child state, react automatically), that is a dedicated script using `herdr agent wait` / `herdr pane read`, not an interactive chat. Say so rather than implying the chat will babysit.

## The Launch Command

`herd-launch` (in `~/.local/bin/`) is the primitive. It is name-agnostic and agent-agnostic:

```bash
herd-launch <name> [--repo <path>] [--kind <agent>] [--spec <path> | --prompt "<text>"] [--dry-run]
```

- `<name>` is any label (not just a ticket); it becomes the workspace label and a lowercased agent slug `[a-z][a-z0-9_-]{0,31}`
- Omit `--spec`/`--prompt` for a fresh session the user drives by hand
- Always offer `--dry-run` first when the user is unsure

Before launching a batch, check for agent-name collisions (`herdr agent list`) — slugs must be unique among live agents.

## Interaction Pattern

1. Notice the work has independent, substantial, parallel pieces (all four criteria)
2. Name the pieces explicitly back to the user
3. Offer fan-out with the concrete `herd-launch` commands you would run
4. On yes: optionally `--dry-run` first, then launch
5. Tell the user to watch the sidebar for `blocked` sessions — that is their cue to jump in
6. Do NOT attempt to supervise the children from this chat

## Anti-Patterns

- **Auto-launching** without asking — the cardinal sin
- **Fanning out a single task** into multiple sessions because the system is "cool"
- **Fanning out sequential work** — dependencies mean one chat or a stack, not parallel sessions
- **Promising live supervision** the chat cannot deliver
- **Launching to explore** before the pieces are nameable
