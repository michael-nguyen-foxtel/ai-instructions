---
name: grill-with-docs
description: A relentless interview to sharpen a plan or design, which also creates docs (ADRs and glossary) as we go.
disable-model-invocation: true
---

Run a `/grilling` session, using the `/domain-modeling` skill.

As decisions crystallise, update `CONTEXT.md` with any new or sharpened domain terms, and offer ADRs for hard-to-reverse trade-offs. Keep `CONTEXT.md` as a **repo-level glossary** — no ticket numbers in the heading, no ticket-specific framing. ADRs go in `docs/adr/`.

At the end:

1. **Produce a spec file** (`<TICKET>-SPEC.md`) with implementation details.

2. **Produce a ready-to-paste prompt** for Kiro IDE or VS Code. This should be a self-contained message the user can copy directly into the editor's chat. Format:

   > Implement the spec in `<TICKET>-SPEC.md`. All design decisions are resolved in `CONTEXT.md`. [any specific instructions about patterns to follow, test locations, etc.]. Generate a Mermaid architecture diagram before starting.

3. **Recommend a Kiro IDE mode** based on what was resolved:
   - **Plain session** (default) — decisions resolved, paste the prompt directly.
   - **Quick Spec** — if the user wants the full Kiro spec UI (requirement → design → task panels). Note: may re-ask some clarifying questions.
   - **Bug Fix mode** — if the ticket is a bug.
   - **No IDE needed** — if the work is simple enough for Copilot/VS Code.

4. **Offer to open the target repo** in either:
   - **Kiro IDE** (complex work): `kiro /path/to/repo`
   - **VS Code** (simpler tasks): `code /path/to/repo`
