---
name: principles
description: A library of short, single-rule engineering principles other skills reference by name. Each is one leading word the agent reasons with — attack-the-premise, fix-root-causes, prove-it-works, build-the-lever, explain-the-number. Use when a skill cites a principle by name, when a fix loop stalls, before trusting a measured number, before declaring a task done, or when deciding whether to do non-trivial work by hand or build the tool that does it.
---

# Principles

A library of short, single-rule principles. Each file states one rule, why it holds, and
when it fires. They exist to be **referenced by name** — a skill or a steering doc names
the principle, and the agent reaches the full rule here.

These are **leading words** (per `writing-for-agents`): a compact concept the agent
reasons with. Naming the principle at the point of use is cheaper and sharper than
re-explaining the behaviour each time.

## The principles

| Principle | Fires when | Rule |
|-----------|-----------|------|
| [attack-the-premise](attack-the-premise.md) | 2+ fixes sharing one premise failed the same gate | Write the premise down and test it directly before the next fix |
| [fix-root-causes](fix-root-causes.md) | Debugging | Fix the first place the system went wrong, not where the symptom surfaced |
| [prove-it-works](prove-it-works.md) | After a task, before declaring done | Verify against the real artifact, not a proxy or "it compiles" |
| [build-the-lever](build-the-lever.md) | Non-trivial edits, migrations, analyses, checks | Build the tool that does or proves the work; it's what a reviewer reruns |
| [explain-the-number](explain-the-number.md) | Before trusting a measured number | Name the limiter and rule out that it measured something else |

## Relationship to existing steering and skills

Several of these reinforce rules already in the environment — they give those rules a
referenceable name:

- **attack-the-premise** sharpens the two-attempt rule in `task-routing` (Error Recovery).
- **fix-root-causes** and **prove-it-works** are the discipline behind `diagnosing-bugs`
  and `build-verify`.
- **build-the-lever** is the "build the codemod, don't hand-edit" move behind `to-tickets`
  wide refactors and Herdr subagent fan-out (the lever written as a skill the subagents read).

Two pstack principles are deliberately **not** ported because the environment already owns
them: *guard-the-context-window* (see `context-management`) and *never-block-on-the-human*
(the system-level default-to-action behaviour).

## Adapted from

The [pstack](https://github.com/cursor/plugins/tree/main/pstack) principle set (MIT),
reworded for this environment and trimmed to the portable, tool-agnostic rules.
