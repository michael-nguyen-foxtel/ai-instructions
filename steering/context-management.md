# Context Management

Decision framework for when to delegate, hand off, or continue inline. Check this at every phase boundary and at session start.

## Session Opening Protocol

Before starting work, state:

- **Scope:** what this session will deliver (one artifact, one decision, one implementation slice)
- **Exit:** what happens when scope is done (handoff, done, next slice in fresh context)
- **Won't do:** what's explicitly out of scope even if related

Every session has a declared boundary. If the task is large, the first job is to decompose it into session-sized pieces and state which piece you're doing NOW.

## What Stays Inline

- Quick decisions, config tweaks, one-liners
- Meta-work: writing skills, steering docs, tooling setup
- Conversations that build on immediately preceding context
- Reviewing subagent output and deciding next steps

## What Gets Delegated

| Signal | Action |
|--------|--------|
| Feature implementation with a clear spec | **Subagent** |
| Research producing a document | **Subagent** |
| CI debugging / log analysis | **Subagent** |
| Work in a different repo or directory | **Subagent** |
| Phase boundary reached (spec → implement) | **Handoff** to new session |
| Scope is done and the next scope is different | **Handoff** to new session |
| Domain shift (CI infra ↔ app code ↔ architecture) | **Handoff** or subagent |
| Independent slices with no shared state | **Parallel subagents** |

### Subagent vs Handoff

- **Subagent**: work that serves THIS session's goal. You dispatched it, you'll use its result to continue. Bounded, reports back.
- **Handoff**: work that belongs to a DIFFERENT goal, or is too large for a subagent, or the current session has served its purpose. You write the handoff doc and stop.

## Rules

### 1. Scope Is Declared, Not Discovered

Don't discover your scope by running out of context. Declare it at the start.

### 2. Exit Before You Must

When your declared scope is done, exit. Don't "just quickly" pick up the next thing. Write the handoff or end the session while context is still cheap.

Observable triggers that you should have exited already:
- Three+ iterations on the same file
- Pasting logs or debugging output into the thread
- Context feels heavy (15+ turns deep, many file reads)
- The domain has shifted from where you started

### 3. Subagent Scoping

Every subagent dispatch must have:

- **Clear deliverable** — what artifact or state change it produces
- **Bounded scope** — one logical task, not "implement everything"
- **Success criterion** — how to tell it succeeded without reading its full output
- **Working directory** — explicit path, never "figure it out"

### 4. Handoff Before Compact

`/handoff` preserves structured state. `/compact` lossy-compresses it. Always prefer handoff when the work will continue.

### 5. Domain Boundaries Are Session Boundaries

If the work shifts from "designing the API" to "debugging why the CI fails," that's a domain shift. Delegate the debugging to a subagent or hand off.

## Anti-patterns

- **"Let me just quickly fix this"** — the most expensive phrase. If it wasn't in your declared scope, it's a new session.
- **Three+ iterations on the same file** — you're implementing without having declared implementation as your scope.
- **Reading 300+ line files to understand implementation detail** — that's implementation research, not decision-making.
- **Context is growing but the declared deliverable isn't closer** — you've drifted.

## Proactive Suggestions

Say these things unprompted when the trigger fires:

- "This is bigger than one session. I'll do [X] now and write a handoff for [Y]."
- "That debugging is going to eat context. Let me dispatch a subagent."
- "My scope was [X] and that's done. Want me to continue into [Y] or hand off?"
- "These tickets are independent — I'll set up parallel worktrees."
