---
name: grill-with-docs
description: A relentless interview to sharpen a plan or design, which also creates docs (ADRs and glossary) as we go.
disable-model-invocation: true
---

Run a `/grilling` session, using the `/domain-modeling` skill.

As decisions crystallise, update `CONTEXT.md` with any new or sharpened domain terms, and offer ADRs for hard-to-reverse trade-offs. Keep `CONTEXT.md` as a **repo-level glossary** — no ticket numbers in the heading, no ticket-specific framing. ADRs go in `docs/adr/`.

At the end:

1. **Produce a spec file** (`<TICKET>-SPEC.md`) in the repo root with implementation details. Include a "Manual Testing" section at the end with:
   - How to run the server/app locally
   - Curl commands, browser steps, or UI actions to verify the change
   - Expected outcomes (what you should see when it works vs when it doesn't)

2. **Produce a ready-to-paste prompt** for Kiro IDE or VS Code. **Plain text only — no backticks, no markdown formatting** (IDE chat inputs break on markdown). Include:
   - The spec file to follow
   - Reference to CONTEXT.md and docs/adr/
   - Which branch to work on (format: `type/TICKET-short-description`)
   - Any repo-specific patterns to follow (test locations, existing utilities)
   - Request a Mermaid architecture diagram if the change involves data flow or middleware

   Example:
   > Implement the spec in WEB-4629-SPEC.md. All design decisions are resolved in CONTEXT.md and docs/adr/. Work on branch feat/WEB-4629-carding-name-filter. Follow the spec exactly. Use the existing test patterns in node-app/test/ for the unit tests. Generate a Mermaid architecture diagram of the middleware chain before starting.

3. **Recommend a Kiro IDE mode** based on what was resolved:
   - **Plain session** (default) — decisions resolved, paste the prompt directly.
   - **Quick Spec** — if the user wants the full Kiro spec UI (requirement → design → task panels). Note: may re-ask some clarifying questions.
   - **Bug Fix mode** — if the ticket is a bug.
   - **No IDE needed** — if the work is simple enough for Copilot/VS Code.

4. **Offer to open the target repo** in either:
   - **Kiro IDE** (complex work): `kiro /path/to/repo`
   - **VS Code** (simpler tasks): `code /path/to/repo`
