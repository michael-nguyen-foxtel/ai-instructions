# AI Coding Agent Instructions

Portable instruction files and workflow commands for AI coding agents. Same conventions and workflows, multiple tool formats.

## Quick Start

```bash
# Copy conventions + commands to your repo
cp AGENTS.md /path/to/repo/AGENTS.md          # Cross-tool standard
cp CLAUDE.md /path/to/repo/CLAUDE.md          # Claude Code
cp -r commands/ /path/to/repo/.claude/commands/ # Claude Code slash commands
```

## Supported Tools

### Convention files (project rules)

| Tool | File | Location |
|------|------|----------|
| **Codex, Cursor, Copilot, Gemini CLI, Aider, Windsurf, Zed** | `AGENTS.md` | Repo root |
| **Claude Code** | `CLAUDE.md` | Repo root |
| **Cursor (dedicated)** | `.cursorrules` | Repo root |
| **Windsurf (dedicated)** | `.windsurfrules` | Repo root |
| **GitHub Copilot** | `copilot-instructions.md` | `.github/` |
| **Gemini CLI (dedicated)** | `GEMINI.md` | Repo root |
| **Personal (Claude Code)** | `CLAUDE.md` | `~/.claude/` |

### Workflow commands (slash commands / prompt templates)

| Tool | How commands work | Install |
|------|-------------------|---------|
| **Claude Code** | Files in `.claude/commands/` become `/commands` | `cp -r commands/ <repo>/.claude/commands/` |
| **Cursor** | Notepads or `.cursor/rules/*.mdc` | Copy content into Cursor notepads manually |
| **Codex** | Paste as prompt or reference in AGENTS.md | Reference in AGENTS.md "workflows" section |
| **Other tools** | Paste content as the opening prompt | Copy-paste from `commands/` |

## Files

```
portable/
├── AGENTS.md              # Project conventions (cross-tool standard)
├── CLAUDE.md              # Same as AGENTS.md (Claude Code discovery)
├── CLAUDE-personal.md     # Global personal preferences (~/.claude/CLAUDE.md)
├── commands/
│   ├── grill.md           # Interview before implementing
│   ├── spec.md            # Synthesise discussion into a spec
│   ├── implement.md       # Plan and build test-first from spec
│   ├── review.md          # Code review against conventions
│   └── diagnose.md        # Systematic bug diagnosis
└── README.md              # This file
```

## Workflow

The commands encode a deliberate workflow:

```
/grill → /spec → /implement → /review
              ↑
         /diagnose (when something breaks)
```

1. **`/grill`** — Resolve ambiguity before coding. Forces you to think through edge cases.
2. **`/spec`** — Captures decisions as a durable artifact. Prevents scope drift.
3. **`/implement`** — Methodical, test-first execution from the spec. No guessing.
4. **`/review`** — Multi-dimensional quality check before merge.
5. **`/diagnose`** — Systematic diagnosis when bugs appear. Prevents guess-and-patch loops.

You don't always need the full pipeline:
- **Trivial change** → just implement directly
- **Medium feature** → `/grill` → `/implement`
- **Complex feature** → full pipeline
- **Bug** → `/diagnose`

## Installation by Tool

### Claude Code

```bash
# Project conventions (commit to repo)
cp AGENTS.md /path/to/repo/AGENTS.md
cp CLAUDE.md /path/to/repo/CLAUDE.md

# Workflow commands (commit to repo)
mkdir -p /path/to/repo/.claude/commands
cp commands/*.md /path/to/repo/.claude/commands/

# Personal preferences (once, not committed)
mkdir -p ~/.claude
cp CLAUDE-personal.md ~/.claude/CLAUDE.md
```

After install, use in Claude Code:
```
/grill      # starts the interview
/spec       # writes the spec
/implement  # builds from spec
/review     # reviews the diff
/diagnose   # debugs a problem
```

### Cursor

```bash
# Project conventions
cp AGENTS.md /path/to/repo/AGENTS.md
# OR
cp AGENTS.md /path/to/repo/.cursorrules
```

For commands: create Cursor "Notepads" with the content from each `commands/*.md` file. Cursor doesn't have a file-based command system equivalent — notepads are the closest.

### GitHub Copilot (VS Code)

```bash
# Project conventions
mkdir -p /path/to/repo/.github
cp AGENTS.md /path/to/repo/.github/copilot-instructions.md
```

Copilot doesn't support custom slash commands from files. Use the convention file only.

### Codex CLI

```bash
# Project conventions
cp AGENTS.md /path/to/repo/AGENTS.md
```

Codex reads `AGENTS.md` natively. For workflows, reference the command prompts in your AGENTS.md or paste them as needed.

### Windsurf

```bash
cp AGENTS.md /path/to/repo/.windsurfrules
```

### Gemini CLI

```bash
cp AGENTS.md /path/to/repo/GEMINI.md
```

## The Cross-Tool Standard: AGENTS.md

`AGENTS.md` is the Linux Foundation Agentic AI Foundation open standard. Read natively by 28+ tools and used in 60,000+ repos. If you maintain only one file, make it this one.

Claude Code is the notable exception — it only reads `CLAUDE.md`. For maximum coverage, keep both (identical content, different filenames).

## Keeping in Sync

`AGENTS.md` and `CLAUDE.md` have identical content:
```bash
cp AGENTS.md CLAUDE.md  # after any edit
```

## What's Included vs Excluded

**Included** (things that affect code generation and git safety):
- Hard safety rules (no force-push, signed commits, no push to main)
- Error recovery protocol
- Commit message format
- Build/test detection
- Changesets awareness
- Stacked PR workflow (Graphite)
- Code conventions and testing philosophy

**Excluded** (multi-step orchestration that needs persistent sessions):
- Spec → ticket decomposition workflow (encoded in commands instead)
- Deploy procedures
- Release email generation
- Jira/Confluence integration
- Session management (handoffs, compaction, tangents)

## Relationship to Kiro Skills

```
┌─────────────────────────────────────────────────┐
│ Kiro CLI (full orchestration)                    │
│ ┌─────────────┐ ┌──────────┐ ┌────────────────┐ │
│ │ Steering    │ │ Skills   │ │ Agents         │ │
│ │ (hard rules)│ │ (30+)    │ │ (tool-scoped)  │ │
│ └─────────────┘ └──────────┘ └────────────────┘ │
└─────────────────────────────────────────────────┘
                      │
                      │ condensed
                      ▼
┌─────────────────────────────────────────────────┐
│ Portable (this folder)                           │
│ ┌──────────────────┐  ┌───────────────────────┐ │
│ │ AGENTS/CLAUDE.md │  │ commands/ (workflow)   │ │
│ │ (conventions)    │  │ grill/spec/implement/ │ │
│ │                  │  │ review/diagnose       │ │
│ └──────────────────┘  └───────────────────────┘ │
│ Works in: Claude Code, Codex, Cursor, Copilot,  │
│           Gemini, Aider, Windsurf, Zed          │
└─────────────────────────────────────────────────┘
```
