# Herdr 0.9.0 native restore vs `herd-restore` + WS-4 plugin

**Date:** 2026-09-15
**Scope:** READ-ONLY investigation. No server stop/restart, no workspace/pane
mutation, no process kills, no file edits (other than writing this doc).
**Question:** Is the local `herd-restore` tooling + its WS-4 `[[startup]]` plugin
still needed, or redundant with Herdr's native session restore?

> ⚠️ **Verification caveat.** This session had no shell/`herdr` CLI tool exposed,
> only file-read + web-fetch + git. So `pgrep -fl kiro-cli`, `ps -o pid,command`,
> `herdr agent list`, `herdr integration status`, and `herdr server
> agent-manifests` **could not be executed live here**. Every claim below is
> sourced from (1) the Herdr 0.9.0 docs, (2) the on-disk lock files I *could*
> read, and (3) the `herd-restore` script's own header comments, which record
> checks "verified live 2026-09-11". Items needing a live CLI run to close are
> flagged **[VERIFY-LIVE]**.

---

## Bottom line first

**Recommendation: (B) KEEP `herd-restore` but add a reconciliation guard**, with a
one-line promotion still gating the WS-4 plugin. Retiring (A) is unsafe because
Kiro has **no Herdr integration**, so it is excluded from Herdr's *native agent
session restore* by design — the resume you observed was **snapshot argv replay**,
which is real but weaker and has gaps `herd-restore` still covers. See the full
justification at the end.

---

## Q1 — External session-ID recovery completeness

Goal: from *outside* a Kiro pane, map a running kiro pane → its Kiro session id.

### Method table

| Method | Covers RESTORED panes? | Covers FRESH panes? | Reliability | How |
|---|---|---|---|---|
| **(a) process argv** `--resume-id <id>` | ✅ Yes | ❌ No | **PARTIAL** | `pgrep -fl kiro-cli` / `ps -o pid,command`; grep the `chat --resume-id <UUID>` substring. Only *resumed* panes carry the flag; a freshly-started `kiro-cli` (no `--resume-id`) mints its id internally after launch, so its argv has no id. |
| **(b) lock-file pid match** | ⚠️ Partial | ⚠️ Partial | **PARTIAL (stale-prone)** | Enumerate `~/.kiro/sessions/cli/*.lock` = `{"pid","started_at"}`; match a pane's pid to the lock's `pid`. Breaks on stale locks and PID reuse (see evidence). |
| **(c) Herdr agent API** | ✅ Yes | ✅ Yes* | **COMPLETE\*** | `herdr agent list` / `herdr agent explain --json`; read the pane's `terminal_title` / `terminal_title_stripped` (`"kiro-cli chat --resume-id <id>"`). *Only carries the id when the launcher put it in the command/title; see caveat.* |

### Evidence gathered

**(a) argv — confirmed by design, not run live here.** The `herd-restore` header
records it, verified live 2026-09-11:

> "Herdr's canonical executable for `--kind kiro` is BARE `kiro-cli`… bare
> `kiro-cli` SILENTLY DROPS `--resume-id` and starts a FRESH session… The
> passthrough after `--` must be `chat --resume-id <id>`."

So the `--resume-id` substring exists in argv **only for panes that were launched
to resume** (via `herd-launch`/`herd-restore`/snapshot-replay). A user who ran
bare `kiro-cli` and got a fresh session has **no id in argv**. → covers restored,
misses fresh. **[VERIFY-LIVE]** re-confirm with `pgrep -fl kiro-cli`.

**(b) lock files — READ LIVE, and they expose the flaw.** The three most-recent
locks in `~/.kiro/sessions/cli/`:

```
b7f37e34-…-b3d0.lock  {"pid":81879,"started_at":"2026-09-15T04:28:34Z"}
74d204b0-…-e85f5.lock {"pid":83355,"started_at":"2026-09-15T04:17:27Z"}
1ded17d8-…-910c4.lock {"pid":81879,"started_at":"2026-09-15T04:12:04Z"}
```

**Two different session locks (`b7f37e34` and `1ded17d8`) claim the same
pid 81879.** A single kiro-cli process cannot hold two sessions at once
(single-process-per-session lock), so **at least one lock is stale**. The
04:28 lock almost certainly owns pid 81879 now; the 04:12 lock is a leftover
(process exited and PID was reused, or the session was resumed under a new
process without the old lock being cleared). This is direct proof that a
pid→session map built from locks alone is **ambiguous** — you can get two
sessions for one pid. Method (b) therefore cannot be the sole source of truth.
It also can't distinguish "lock present, process dead" from "live" without a
`ps`/`kill -0` liveness check (which `herd-restore`'s `session_is_active()`
already does, and which is exactly why it does it).

**(c) Herdr API — the clean path, per docs.** Two doc facts:
- `agents` doc, *Custom status labels*: agent sidebar rows can expose
  `terminal_title` (latest OSC 0/2 title) and `terminal_title_stripped`. These
  are "**ephemeral across a cold restart** and remain independent of metadata."
- `agents` doc, *Debug integration state*: `herdr agent list` and `herdr agent
  explain <target>` are the inspection entry points.

The background note saw `terminal_title(_stripped)` = `"kiro-cli chat
--resume-id <id>"` in an `agent_started` result. **[VERIFY-LIVE]** the open
question is whether that field is **queryable for already-running agents** (not
just at start) via `herdr agent list --json` / `herdr agent explain --json`.
If yes, it is the cleanest recovery path because Herdr tracks the pane→argv
link itself. Caveat: `terminal_title` only carries the id if the launch command
contained it — a **fresh** pane's title is just `kiro-cli`, so (c) inherits (a)'s
fresh-pane gap *unless* Herdr also exposes the pane's live foreground-process
argv (which, post-resume, a fresh session mutates its own title away from anyway).

### Recommended COMPLETE approach for Q1

No single method is complete. The robust map is **(c) primary + (a) confirm +
(b) liveness**, in this order, per pane:

1. **(c)** `herdr agent list --json` → for each Kiro pane, take
   `terminal_title_stripped`; extract `--resume-id <id>` if present. *(covers
   restored/resumed panes cleanly, and is the pane→id link Herdr itself owns.)*
2. **(a)** For any Kiro pane whose title has no id, fall back to that pane's
   live process argv (`ps -p <pid> -o command=` using the pid Herdr reports for
   the pane) and grep `--resume-id`. *(catches resumed panes whose title drifted.)*
3. **Fresh panes** (no id in title *or* argv): read `$KIRO_SESSION_ID`
   **inside** the pane — but that's excluded by the question. Externally, the
   only fallback is **(b)** *inverted*: find the `*.lock` whose `pid` == the
   pane's live pid **and** whose process is alive (`kill -0`), then that lock's
   filename is the session id. This is the sole external way to recover a
   **fresh** session's id, and it's the one method that closes (a)+(c)'s gap.

So the **combination that covers BOTH restored and fresh** is **(c/a) for
resumed panes + (b)-inverted-with-liveness for fresh panes**. Neither the argv
nor the lock nor the title is individually complete; the union is. **[VERIFY-LIVE]**
whether `herdr agent list --json` returns the pane pid + title for running
agents would let a guard implement this without ever entering a pane.

---

## Q2 — Herdr 0.9.0 native restore guarantees for Kiro

### The decisive fact: Kiro has NO integration

`agents` doc, *Supported agents* table (0.9.0), verbatim row:

```
Kiro CLI │ screen manifest │ none
```

`Integration role = none`. Compare Claude Code / Codex / etc. = `session`.
The `session-state` doc, *Native agent session restore*:

> "Herdr only resumes panes that reported a **native session reference through a
> current official Herdr integration**."
> "Unsupported, missing, invalid, duplicated, or stale session references
> **restore as normal shells in the saved pane directory**."

And the `integrations` doc lists every agent Herdr will resume — **Kiro is not in
that list** (Pi, OMP, Claude, Codex, Copilot, Devin, Droid, Kimi, Qoder, Qwen,
Cursor, Grok, OpenCode, Kilo, Hermes, MastraCode, Antigravity — no Kiro).

**Therefore Herdr's *native agent session restore* does NOT and cannot apply to
Kiro.** There is no Kiro integration to install; `herdr integration install kiro`
is not a thing. **[VERIFY-LIVE]** `herdr integration status` will show no Kiro row.

### So what did we observe? — Snapshot restore replaying the argv

`session-state` doc, *Snapshot restore*:

> "If the Herdr server stops and starts again, the original pane processes are
> gone. Herdr restores the saved session shape: **workspaces, tabs, panes, cwd,
> layout, and focus**. … Panes that cannot use a stronger restore path **come
> back as new shells in their saved directories**."

The *What survives* table, row **Server restart**: "Agent conversation resumes =
**Only with native agent session restore**." Kiro can't use that path.

**Reconciliation of the background observation.** After `herdr server stop` +
relaunch, the Kiro pane came back running `kiro-cli chat --resume-id <id>`
(id visible in `pgrep`). That is **not** native agent session restore — it is
**snapshot restore re-creating the pane with its saved command line**. Because
`herd-launch`/`herd-restore` originally started the pane with the explicit argv
`… -- chat --resume-id <id>`, Herdr persisted *that exact command* as the pane's
command and **re-ran it verbatim** on restart. The conversation came back only as
a *side effect* of the argv already naming the session — Herdr didn't know it was
a Kiro session id; it just replayed the command string it had saved.

### What Herdr persists about a pane, and the gaps

| Herdr persists (snapshot) | Does it bring Kiro conversation back? |
|---|---|
| workspace/tab/pane shape, **cwd**, layout, focus | Shape yes; conversation only if the saved **command** already contained `--resume-id`. |
| the pane's **command line** (argv) | ✅ if launched with `chat --resume-id <id>` — replays it → resumes. ❌ if launched bare `kiro-cli` — replays bare `kiro-cli` → **fresh** chat. |
| recent screen contents | Only with `[experimental] pane_history = true` (off by default; and it's *replay of text*, not a live session). |

**Cases where Herdr will NOT bring a Kiro session back:**
1. **Bare-launched panes.** A pane started as plain `kiro-cli` (no resume argv)
   restores to a **fresh** chat — the saved command has no id to replay. This is
   the majority case for panes a human started by hand.
2. **Crash / non-graceful stop.** Snapshot restore relies on the saved
   `session.json` shape. Native restore is explicitly "**after a Herdr server
   restart**"; the *What survives* table treats the surviving-process paths
   (detach/handoff) separately. A hard crash that didn't flush the snapshot
   loses the shape. **[VERIFY-LIVE]** exact crash-vs-graceful flush behaviour.
3. **`resume_agents_on_restore` is irrelevant to Kiro** — it only governs the
   native path Kiro can't use. Even set to default `true`, Kiro gets snapshot
   argv replay, not native restore.
4. **Stale / duplicate ids.** Per the doc, "duplicated or stale session
   references restore as normal shells." The lock evidence in Q1 shows dup pids
   already occur; a saved argv pointing at a since-deleted session id replays
   `chat --resume-id <gone>` → Kiro **silently starts fresh** (the exact bug the
   `herd-restore` guard `[ -f "$SESSIONS_DIR/$id.json" ]` was written to catch).

### Answer to Q2

Herdr 0.9.0 **does not guarantee** native Kiro conversation restore. Kiro has
**no integration**, so the native path is unavailable to it by design. What
actually happens across `server stop` + relaunch is **snapshot restore replaying
the saved pane argv** — which resumes the conversation **only when the pane was
originally launched with `chat --resume-id <id>`** (i.e. by our own tooling), and
falls back to a fresh chat for bare-launched panes, deleted-session ids, or lost
snapshots. It is **best-effort, launcher-dependent, and graceful-stop-dependent**,
not a guarantee.

---

## Recommendation (full justification)

**Choose (B): KEEP `herd-restore`, add a reconciliation guard.** Rejecting the
alternatives:

- **(A) RETIRE — rejected.** Native restore *doesn't cover Kiro at all*
  (integration role `none`). The resume we saw was snapshot argv replay, which
  only works for panes our tooling launched with `--resume-id` and silently
  fails to fresh for bare panes, deleted ids, and (likely) crashes. Retiring
  removes the deterministic guards (`session.json` existence check,
  live-lock/`session_is_active` skip) that catch exactly those silent-fresh
  cases. Net: we'd trade a known-good safety net for a partial, undocumented
  side effect.
- **(C) KEEP as fallback-only — insufficient.** The *observed core problem* is
  not that native restore misses cases — it's that `herd-restore` **duplicates
  workspaces** by rebuilding from the manifest *without checking what Herdr
  already restored (via snapshot argv replay)*. A pure fallback still collides
  because it doesn't know a snapshot-replayed pane is already live for that id.
- **(B) KEEP + reconcile — correct.** The one change that fixes the duplication
  is a **pre-rebuild reconciliation pass**: before creating a workspace for a
  pinned id, check whether that session id is **already live** and skip/rename it.
  `herd-restore` already has *half* of this — `session_is_active()` checks the
  lock's pid liveness. The missing half is checking Herdr's *own* live panes
  (snapshot-replayed ones), because a freshly snapshot-restored pane may hold the
  session before its lock is re-established, or under a different pid than the
  stale lock. Implement the guard using the Q1 map:

  1. Enumerate live Kiro panes via **(c)** `herdr agent list --json`; extract
     each pane's `--resume-id <id>` from `terminal_title_stripped`.
  2. Build the set of already-live session ids.
  3. In `herd_restore_one`, **before** `herdr workspace create`, skip any pinned
     id already in that set (Herdr already brought it back) — this is the
     reconciliation that prevents the duplicate workspace.
  4. Keep the existing `session.json`-exists and lock-liveness guards as the
     deterministic backstops for ids Herdr did *not* restore.

  This makes `herd-restore` idempotent against Herdr's snapshot replay: it only
  rebuilds the pinned sessions Herdr **failed** to bring back (bare-launched,
  crashed, or never-argv'd panes), and never double-creates one Herdr already
  replayed.

**WS-4 plugin:** keep it, still gated. The `[[startup]]` hook is the right
trigger (it "runs once after Herdr restores the session… and again on live
handoff"). But it must inherit the same reconciliation guard **before** the
step-1→step-3 promotion (`DRY_RUN=false`) — otherwise flipping it live would
auto-duplicate on every restart, which is the exact failure being investigated.
Promote to live only *after* the reconciliation pass exists and a real restart
confirms the hook skips already-live ids.

---

## Open items to close with a live CLI run — [VERIFY-LIVE]

1. `pgrep -fl kiro-cli` + `ps -o pid,command` — confirm which live pid owns
   session `b7f37e34` vs the stale `1ded17d8` lock, and confirm fresh panes
   truly have no `--resume-id` in argv.
2. `herdr agent list --json` / `herdr agent explain --json` — confirm
   `terminal_title` / `terminal_title_stripped` is queryable for **already
   running** agents (not just at `agent_started`). This is the linchpin for the
   reconciliation guard.
3. `herdr integration status` — confirm no Kiro integration row exists
   (expected, per docs).
4. `herdr server agent-manifests` — confirm Kiro is detected purely by screen
   manifest with integration `none`.
5. Crash vs graceful `server stop`: whether an un-flushed snapshot loses the
   pane shape entirely (would widen the set `herd-restore` must still cover).

## Sources

- Herdr 0.9.0 **Session state and restore** — `https://herdr.dev/docs/session-state/`
  (What survives table; Snapshot restore; Native agent session restore; the
  integration-version table that omits Kiro).
- Herdr 0.9.0 **Integrations** — `https://herdr.dev/docs/integrations/`
  (install list omits Kiro; "How Herdr uses integrations" lifecycle vs session).
- Herdr 0.9.0 **Agents** — `https://herdr.dev/docs/agents/`
  (**Supported agents** table: `Kiro CLI │ screen manifest │ none`; Status
  authority; Detection manifests).
- Herdr 0.9.0 **Plugins** — `https://herdr.dev/docs/plugins/`
  (Startup hooks: fire after restore + on handoff, not on link/enable/attach;
  `HERDR_PLUGIN_STATE_DIR` contract).
- Local: `~/.kiro/sessions/cli/*.lock` (pid collision evidence, read live).
- Local: `bin/herd-restore` header + `session_is_active()` (resume mechanics
  "verified live 2026-09-11"); `bin/herdr-restore-plugin/{herdr-plugin.toml,
  restore-startup.sh}` (WS-4 dry-run gate).
