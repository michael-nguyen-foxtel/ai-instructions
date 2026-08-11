---
name: grill-with-docs
description: A relentless interview to sharpen a plan or design, which also creates docs (ADRs and glossary) as we go.
disable-model-invocation: true
---

Run a `/grilling` session, using the `/domain-modeling` skill.

As decisions crystallise, update `CONTEXT.md` with any new or sharpened domain terms, and offer ADRs for hard-to-reverse trade-offs. Keep `CONTEXT.md` as a **repo-level glossary** — no ticket numbers, no ticket-specific framing. ADRs go in `docs/adr/`.

When the grilling completes, recommend the next step:

- "Run `/to-spec` to write this up as a spec."
- Or if the work is small enough: "This is small enough to implement directly — want me to just do it?"
