---
name: prototype
description: Build a throwaway prototype to answer a design question. Use when the user wants to sanity-check whether a state model or logic feels right, or explore what a UI should look like.
---

# Prototype

A prototype is **throwaway code that answers a question**. The question decides the shape.

## Pick a branch

Identify which question is being answered:

- **"Does this logic / state model feel right?"** → [LOGIC.md](LOGIC.md). Build a tiny interactive terminal app that pushes the state machine through cases that are hard to reason about on paper.
- **"What should this look like?"** → [UI.md](UI.md). Generate several radically different UI variations toggleable from one route.

If the question is ambiguous, default to whichever branch better matches the surrounding code (a backend module → logic; a page or component → UI) and state the assumption.

## Rules (both branches)

1. **Throwaway and clearly marked.** Locate near where it will actually be used. Name it so a reader can see it's a prototype, not production. Follow the project's existing routing/file conventions.
2. **One command to run.** Whatever the project's task runner supports. The user must be able to start it without thinking.
3. **No persistence by default.** State lives in memory. Persistence is the thing being checked, not something to depend on.
4. **Skip the polish.** No tests, no error handling beyond what makes it runnable, no abstractions.
5. **Surface the state.** After every action, print or render the full relevant state so the user can see what changed.
6. **Delete or absorb when done.** When the question is answered, either delete or fold the validated decision into real code.

## When done

The *answer* is the only thing worth keeping. Capture it somewhere durable (commit message, ADR, issue, or NOTES.md next to the prototype) along with the question it was answering. Then delete the prototype.
