# `bin/` — Herdr session tooling

Helper scripts that wrap the `herdr` CLI to manage Kiro session save/restore. They are deployed to `~/.local/bin` by the repo's `setup.sh` (executable bit preserved). The compiled `herdr` binary itself is **not** version-controlled here — only these wrappers.

This README is the deep reference. The operational rules an agent needs on every session live in `steering/herdr.md`; read this only when editing or debugging the scripts.

## The scripts

| Script | Role |
|--------|------|
| `herd-launch` | Create a workspace and start an agent in it. Starts a **fresh** session (no history). Accepts a spaced/mixed-case label; derives a legal agent slug. |
| `herd-sessions` | List Kiro CLI sessions with age, cwd, title. Windowed to 14 days by default. |
| `herd-pin` | Pin a session (name → session-id → cwd) to the restore manifest. |
| `herd-pin-all` | Best-effort pin of every currently resolvable session. |
| `herd-pin-current` | Pin the session in the current pane. |
| `herd-restore` | Rebuild every pinned session after a restart, resuming with history. |
| `herd-checkpoint` | Write a human-readable map of running workspaces + pin the resolvable subset. |

Coupling: `herd-checkpoint` drives the others; `herd-pin-all`, `herd-pin-current`, and `herd-restore` all call `herd-pin`. They must travel together.

## Core model: pinning is the only path to history

Herdr persists workspace/pane **layout** across a restart, but not the binding from a workspace to its Kiro conversation. So after a restart a workspace comes back as an empty shell (`agent_status: unknown`) unless its session was **pinned**.

- `herd-pin` writes `name<TAB>session-id<TAB>cwd` to `~/.config/herd/restore.tsv`.
- `herd-restore` reads that manifest and runs `herdr agent start … -- --resume-id <id>` for each, bringing the conversation back.
- `herd-launch` does **not** resume — it always starts fresh. Good for a clean start, useless for continuing work.

Practical consequence: pin sessions worth keeping **as they are created**, not "before a restart" (you rarely get advance notice of a restart).

## Label vs slug (herd-launch)

A Herdr agent slug must match `[a-z][a-z0-9_-]{0,31}`. Early versions used the same string for both the workspace label and the agent slug, so a friendly label like `"Quicksilver Migration"` was rejected.

Now `herd-launch`:
- takes the label verbatim (spaces, caps allowed) for the workspace,
- derives the slug: lowercase, collapse runs of illegal chars to `-`, trim, ensure a leading letter, cap at 32 chars,
- accepts `--slug` to override the derived value.

This matches what `herd-checkpoint` records (real workspace labels, which have spaces), so the checkpoint's rebuild hints are copy-pasteable.

## Gotchas (hard-won)

### `grep -P` is not portable — it silently wiped the manifest

macOS ships BSD grep, which has **no `-P` (PCRE)** flag. `herd-pin` originally de-duplicated the manifest with:

```bash
grep -v -P "^${name}\t" "$MANIFEST" > "$tmp" 2>/dev/null || true
mv "$tmp" "$MANIFEST"
```

On macOS, `grep -P` errors out → `2>/dev/null` hides the error → `|| true` continues → `$tmp` is **empty** → `mv` overwrites the manifest with nothing. Net effect: **every `herd-pin` wiped all existing pins and kept only the one just added.** This was the root cause of "my pinned sessions never come back — only ever one."

Fix: use `awk` field matching, which is portable:

```bash
awk -F'\t' -v n="$name" '$1 != n' "$MANIFEST" > "$tmp"
mv "$tmp" "$MANIFEST"
```

Lesson: on macOS, prefer `awk` / `sed -E` / `grep -E` over `grep -P`. If a pipeline mutates a file in place, never let a silenced error leave the intermediate empty before an overwrite.

### Trailing newline before append

A manifest written without a trailing newline glues the next appended pin onto the last line, corrupting both. `herd-pin` now checks the last byte (`tail -c1 | od`) and adds a newline before appending.

### `herdr workspace close` takes a positional id

It's `herdr workspace close <workspace_id>`, not `--workspace <id>`. The `--workspace` form is used by `herdr worktree remove`, which is a different (worktree-aware) operation.

### Identifying a session for a workspace

`herd-sessions` shows cwd + first-message text. When a directory (e.g. a generic `SourceCode`) hosts many sessions, **file size** is the fastest discriminator: a real conversation is hundreds of KB; an empty/aborted shell is ~1 KB.

## Deployment & sync-back

`setup.sh` copies `bin/*` to `~/.local/bin` and `chmod +x`es them, in `--all`, `--universal`, and interactive modes.

To sync live edits back into the repo, copy per-file — **not** `rsync --delete`, because `~/.local/bin` also holds the `herdr` binary and unrelated tools that must never be pulled in:

```bash
for s in bin/*; do cp "$HOME/.local/bin/$(basename "$s")" "$s"; done
```

## Portability notes

- Target OS is macOS (BSD userland): `stat -f`, `md5 -r`, no `grep -P`, BSD `sed`.
- Scripts are bash 3.2 compatible where noted (`herd-checkpoint` avoids associative arrays) because macOS ships bash 3.2.
