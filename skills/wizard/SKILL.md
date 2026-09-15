---
name: wizard
description: Generate a guided, resumable operator walkthrough for the human-only steps of a task — provisioning, credentials, CI secrets, third-party dashboards, cutovers. Use when a workflow reaches steps the agent cannot perform itself and a human must be walked through them with verification. Model-invoked; other skills may pull it in.
---

# Wizard

> **v0.1 — first cut.** Built to be used, then re-evaluated. Expect tuning once it
> has run against a real task. Design source: the operator runbooks in
> `.kiro/handoffs/` (finals-pricing, catch-the-bus) are *evidence* of the pattern,
> not its definition — `wizard` is defined by its job below, not by those examples.

## Job

Turn the **human-only** steps of a task into a **guided walkthrough**: a numbered
sequence that instructs the operator, runs the checks it *can* automate, and gates on
a human confirmation for the steps it cannot. It does NOT perform the manual steps
itself, and it is NOT setup-from-scratch. It produces the artifact; the human drives.

The root reason it exists: when a workflow hits a step the agent cannot do — click a
dashboard, enter a CI secret, flip a version field, approve a cutover, tap a physical
device — the alternative is a prose checklist the operator reads and hopes. A wizard
replaces "here's what to do (good luck)" with "do this step, here's how I verified it,
now the next" — and it can be stopped and resumed.

## When to use

- A skill or the user reaches steps outside the agent's reach (GUI, provisioning,
  credentials, third-party consoles, hardware, human approvals) and wants them
  walked through with verification rather than listed as prose.
- Model-invoked: e.g. `deploy-fiso` pulling in a wizard for the FISO→WordPress version
  step, or a coupler cutover.

**Not** for steps the agent can just do (edit a file, run a build) — do those directly.
**Not** a replacement for a reference runbook that captures deep context/judgement
(keep that as prose); a wizard is the *executable gate sequence* alongside it.

## What it generates

A single self-contained bash script (`<task>-walkthrough.sh`) that, for each step:

1. **Instructs** — prints exactly what the operator must do, in plain language.
2. **Verifies where it can** — runs a check the agent CAN automate and reports pass/fail:
   - `aws s3 ls …` to confirm an upload exists (use the project's `--profile`)
   - `curl -sf …` to confirm an endpoint/banner is live
   - `gh run list` / `gh release view` to confirm a workflow/tag
   - a value echoed back and confirmed by the operator when no machine check exists
3. **Gates** — for a purely manual step, prompts `Done? [y/N]` (or "paste the value")
   and does not advance until confirmed.
4. **Is resumable** — writes a step sentinel (e.g. `.<task>-walkthrough.state`) after
   each completed step; re-running resumes at the first incomplete step instead of
   redoing everything. A half-done run is never restarted from scratch.

### Skeleton the generator emits

```bash
#!/usr/bin/env bash
set -euo pipefail
STATE_FILE=".${TASK}-walkthrough.state"
done_through() { [ -f "$STATE_FILE" ] && cat "$STATE_FILE" || echo 0; }
mark() { echo "$1" > "$STATE_FILE"; }
step() {  # step <n> <title>
  [ "$(done_through)" -ge "$1" ] && { echo "✓ step $1 already done — skipping"; return 1; }
  echo ""; echo "── Step $1: $2 ──"; return 0
}
confirm() { read -r -p "   $1 [y/N]: " a; [ "$a" = y ] || [ "$a" = Y ]; }

if step 1 "Enable the product in the VCC"; then
  echo "   Open <url>, set price/dates per the runbook, Save EACH section separately."
  confirm "Saved and re-expanded to confirm persistence?" || { echo "stopping — resume later"; exit 0; }
  mark 1
fi

if step 2 "Confirm the tile is live"; then
  if curl -sf "<join-page-url>" | grep -q "<expected-label>"; then
    echo "   ✓ verified: tile is live"; mark 2
  else
    echo "   ✗ not seen yet — check the VCC save, then re-run this script to retry"; exit 1
  fi
fi
```

## How to build the walkthrough (the generation process)

1. **Take the step list** from the caller (a spec, a runbook, or the conversation).
2. **Classify each step:** agent-doable (do it directly, not in the wizard), or
   human-only (goes in the wizard). Only human-only steps belong here.
3. **For each human-only step, find the strongest verification the agent CAN run**
   after it — an S3/HTTP/gh check beats a paste-back, a paste-back beats nothing.
   Never claim a step is verified by a check that doesn't actually prove it.
4. **Order and gate** the steps; add the resume sentinel.
5. **Bake in the guardrails** the task carries as refusals in the script, not just
   comments — e.g. it must never `git push` to a protected branch, never delete the
   thing a rollback depends on, never echo a secret value (reference by name).
6. **Adapt to this environment, don't copy upstream:** macOS `md5 -r` (not `md5sum`),
   `pbcopy` for clipboard, AWS `--profile foxsports-web-powerdev-185314292360` (or the
   task's profile), `gh auth token` for GitHub. Detect platform where it matters.
7. **Emit the script + a one-line run instruction.** Tell the operator it is resumable
   (safe to Ctrl-C and re-run).

## Safety (the generated script must obey)

- **Instructs and verifies; never performs** a destructive or protected action itself.
- **Never** pushes to `main`/`master`/`develop`/`qa`, never force-pushes (see
  `task-routing.md`). If a step needs that, it instructs the human and stops.
- **Secrets by name, never value** — never echo or write a secret in plaintext.
- **Verification must be honest** — if the agent cannot actually check a step, say so
  and fall back to an explicit human confirm; do not fake a green check.
- **Resumable and idempotent** — re-running never repeats a completed side-effecting
  step.

## Output

- The walkthrough script, saved next to the task's working files.
- A short note: what it automates, what it gates on the human, and the run command.
