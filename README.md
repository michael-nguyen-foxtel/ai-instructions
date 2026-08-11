# AI Instructions

Version-controlled snapshot of my AI agent skills and steering configuration.

## Architecture

```
~/.kiro/skills/     ← LIVE (edit here, immediate effect in Kiro CLI + IDE)
~/.kiro/steering/   ← LIVE (always-on context for all sessions)
         │
         │  rsync (periodic checkpoint)
         ▼
this repo           ← VERSION HISTORY (git log of how skills evolve)
```

**This repo is not a distribution mechanism.** It's a versioned backup of what lives at `~/.kiro/`.

## Structure

```
├── skills/          ← mirrors ~/.kiro/skills/ (all universal skills)
├── steering/        ← mirrors ~/.kiro/steering/ (always-on context)
├── copilot/         ← lightweight Copilot instruction files
├── agents/          ← Kiro CLI subagent definitions
├── setup.sh         ← installs skills into ~/.kiro/ (for Kiro CLI)
├── install.sh       ← installs Copilot instructions into a repo
└── README.md
```

---

## The Workflow

### The Main Flow

The idea→ship spine. Each skill's output feeds the next:

```
/grill-with-docs → /to-spec → /to-tickets → /implement-from-spec → /code-review → PR
```

### When to Use Which Entry Point

| Situation | Entry point | What happens |
|-----------|-------------|--------------|
| **Large / foggy** — can't spec it yet | `/wayfinder` | Chart a map of decisions → resolve them → `/to-spec` → tickets → implement |
| **Medium** — clear enough to spec, multiple slices | `/grill-with-docs` | Grill → `/to-spec` → `/to-tickets` → implement per ticket |
| **Small** — single feature, one session | `/grill-with-docs` | Grill → `/to-spec` → `/implement-from-spec` directly |
| **Trivial** — typo, one-liner, config tweak | Direct | Just do it |

### How Each Skill Works

#### 1. `/grill-with-docs` — Resolve Decisions

Runs a rounds-based interview that maps your plan as a **design tree**. Each round asks the whole "frontier" — every decision whose prerequisites are already settled:

```
❓ Q1 - **State management**: Should the cart use local state or a shared store?
➡️ Local state — the cart is page-scoped

❓ Q2 - **Error handling**: Inline validation or toast notifications?
➡️ Inline — matches existing form patterns
```

Answer by number: "Q1 agree, Q2 change to inline + summary toast on submit."

Also maintains the domain glossary (`CONTEXT.md`) and produces ADRs for hard-to-reverse decisions.

**Done when:** Frontier is empty — every branch visited, nothing assumed.

#### 2. `/to-spec` — Write It Up

Synthesises the grilling into a spec file at `.kiro/specs/<TICKET>-SPEC.md`. No interview — just writes up what was decided. Includes problem statement, user stories, implementation decisions, testing decisions, and out-of-scope.

**When to use:** After grilling is complete and you say "write the spec" or "spec this up."

#### 3. `/to-tickets` — Break Into Slices

Splits a spec into **vertical-slice tickets** — each cuts through every layer (schema, API, UI, tests) and is independently demoable. Each ticket declares its **blocking edges** — which tickets must complete first.

Publishes to Jira with native "Blocks" links. Always quizzes you before publishing.

**When to skip:** If the work fits in one session, go straight from spec to implement.

#### 4. `/implement-from-spec` — Build It

Implements one ticket or spec. Uses TDD at pre-agreed seams. Typechecks regularly. Full test suite at the end. Self-reviews with `/code-review` before committing.

#### 5. `/code-review` → PR

Reviews the diff against team conventions and the originating spec. Creates a PR via `/pull-requests`.

---

### Shaping Skills (Exploration)

| Skill | When to use |
|-------|-------------|
| `/wayfinder` | Effort too big for one session — chart a map of decisions, resolve them one-at-a-time |
| `/prototype` | "How should it look?" or "How should it behave?" — make a throwaway artifact to react to |
| `/research` | Need facts from docs, APIs, or code — fires a background agent |

### Upkeep Skills

| Skill | When to use |
|-------|-------------|
| `/improve-codebase-architecture` | Find modules worth refactoring (visual HTML report) |
| `/diagnosing-bugs` | Hard bug — systematic diagnosis, never guess-and-patch |
| `/resolving-merge-conflicts` | In-progress merge/rebase conflict — hunk by hunk |

### Productivity Skills

| Skill | When to use |
|-------|-------------|
| `/grill-me` | Stress-test an idea (no docs output, just decisions) |
| `/handoff` | Compress session state so another agent/session can continue |
| `/wait-what` | Last message didn't land — re-pitch in plain English |
| `/teach` | Learn a topic across multiple sessions |
| `/writing-for-agents` | Reference for writing skills and agent docs |

### Ops Skills

| Skill | When to use |
|-------|-------------|
| `/deploy-fiso` | Deploy widget packages to S3 + notify FISO |
| `/deploy-coupler` | Deploy coupler to Elastic Beanstalk |
| `/release-email` | Generate formatted release notification |
| `/version-bump` | Version bump + release PR |

### Reference Skills (invoked by other skills)

| Skill | What it provides |
|-------|-----------------|
| `/grilling` | The rounds-based interview loop (design tree + frontier) |
| `/domain-modeling` | Maintains CONTEXT.md glossary + ADRs |
| `/tdd` | Red-green-refactor at seam boundaries |
| `/codebase-design` | Deep modules vocabulary |
| `/build-verify` | Post-change lint + test loop |

---

## Phase Boundaries

At the boundary between skills (e.g., grilling done → spec time), decide what to do with context:

1. **Continue** — keep working (only move that keeps conversation as primary source)
2. **Subagent** — fire off tightly-scoped AFK work
3. **`/handoff`** — when work needs to travel (different repo, different person)
4. **`/compact`** — last resort (you lose nuance)

---

## Syncing

### Edit skills (immediate effect)

Edit directly in `~/.kiro/skills/`. Changes are live immediately in Kiro CLI and Kiro IDE.

### Checkpoint to git

```bash
cd ~/Documents/SourceCode/ai-instructions
rsync -av --delete ~/.kiro/skills/ ./skills/
rsync -av --delete ~/.kiro/steering/ ./steering/
git add -A && git commit -m "sync: $(date +%Y-%m-%d)"
git push
```

## Installation

### Install skills into Kiro CLI

```bash
git clone https://github.com/michael-nguyen-foxtel/ai-instructions.git
cd ai-instructions
./setup.sh
```

This installs **universal skills only** (grilling, specs, tickets, TDD, prototyping, etc.) into `~/.kiro/skills/`. Team-specific skills (deploys, release emails) are excluded by default.

```bash
# If you're on the same team and want everything:
./setup.sh --all
```

After installing, review `~/.kiro/skills/` and edit anything that references team-specific config (Jira project keys, cloud IDs, etc.) to match your setup.

### Install Copilot instructions into a repo

```bash
./install.sh /path/to/your-project
```

This copies the 5 Copilot instruction files into `.github/instructions/`.

---

## Parallel Work with Git Worktrees

When `/to-tickets` produces independent tickets (no blocking edges between them), you can implement them in parallel using git worktrees:

```bash
# From the repo root — each ticket gets its own worktree
git worktree add ../quicksilver-WEB-4601-ts-foundation -b feat/WEB-4601-ts-foundation
git worktree add ../quicksilver-WEB-4602-vitest -b feat/WEB-4602-vitest

# Each worktree is a full checkout — run install in each
cd ../quicksilver-WEB-4601-ts-foundation && pnpm install
cd ../quicksilver-WEB-4602-vitest && pnpm install
```

Then run separate Kiro CLI sessions in each directory. No branch switching, no stale state.

**Cleanup after merge:**
```bash
git worktree remove ../quicksilver-WEB-4601-ts-foundation
```

---

## Acknowledgements

This workflow is heavily based on [Matt Pocock's Skills](https://github.com/mattpocock/skills) ([aihero.dev/skills](https://www.aihero.dev/skills)) — a practical skill system for engineers who want to use AI without giving up their standards. The main flow (grill → spec → tickets → implement → review), the rounds-based grilling, vertical-slice tickets with blocking edges, wayfinder for large efforts, and the writing-for-agents reference are all adapted from his work.

MIT licensed. Adapted for Jira, Kiro CLI, and our team's conventions.
