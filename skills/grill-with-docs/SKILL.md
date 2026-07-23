---
name: grill-with-docs
description: A relentless interview to sharpen a plan or design, which also creates docs (ADRs and glossary) as we go.
disable-model-invocation: true
---

Run a `/grilling` session, using the `/domain-modeling` skill.

As decisions crystallise, update `CONTEXT.md` with any new or sharpened domain terms, and offer ADRs for hard-to-reverse trade-offs. Keep `CONTEXT.md` as a **repo-level glossary** — no ticket numbers in the heading, no ticket-specific framing. ADRs go in `docs/adr/`.

At the end:

1. **Produce a spec file** (`.kiro/specs/<TICKET>-SPEC.md`) with implementation details. Include:
   - Summary of what to build
   - Acceptance criteria (including edge cases from the adversarial QA pass)
   - File locations to create/modify
   - Test scenarios mapped to acceptance criteria
   - A "Manual Testing" section with:
     - How to run the server/app locally
     - Curl commands, browser steps, or UI actions to verify the change
     - Expected outcomes (what you should see when it works vs when it doesn't)

2. **Create the working branch** using format: `type/TICKET-short-description`

3. **Recommend next step:**
   - **Orchestrated implementation** (default): "Run `/implement-from-spec .kiro/specs/<TICKET>-SPEC.md` to implement, test, review, and ship."
   - **Manual implementation**: If the user prefers hands-on, provide a one-line instruction for the IDE: "Implement the spec in `.kiro/specs/<TICKET>-SPEC.md`. All design decisions are resolved in CONTEXT.md and docs/adr/."
