#!/usr/bin/env bash
# restore-startup.sh — Herdr [[startup]] hook for the herd.restore plugin.
#
# Fires once after Herdr restores the session (and again on live handoff), reads
# the pinned-session manifest from HERDR_PLUGIN_STATE_DIR, and rebuilds each
# pinned Kiro session by SOURCING the shared core in herd-restore.
#
# ── WS-4 SAFE-STEP MODE (step 1 of 3) ─────────────────────────────────────
# This hook is deliberately in DRY-RUN: it echoes the `herdr workspace create`
# / `herdr agent start … -- chat --resume-id <id>` commands it WOULD run, but
# creates nothing. It reuses the REAL code path (herd_restore_rebuild_all with
# DRY_RUN=true) rather than a throwaway echo, so verifying the dry-run also
# verifies the manifest read and the command shape.
#
# Promotion to live (WS-4 step 3) is a ONE-LINE change: set DRY_RUN=false below.
# Do that only AFTER a real restart has confirmed (via `herdr plugin log list`)
# that this hook fires and reads the manifest. See the WS-4 handoff.
#
# Env provided by Herdr at startup (0.9.0): HERDR_PLUGIN_STATE_DIR, HERDR_BIN_PATH,
# HERDR_PLUGIN_ROOT, HERDR_PLUGIN_EVENT=startup. cwd = HERDR_PLUGIN_ROOT.

set -euo pipefail

# ── WS-4 step 3: ARMED. The hook now performs real reconcile actions —
# resume-into-bare-shell + fresh-workspace fallback. Verified safe: Herdr
# restores bare panes only (never auto-resumes Kiro; herdr-server.log, 6
# restarts), so there is no hook-vs-Herdr race for the agent. Skip branches
# (live pane / superseded pin) are no-ops. Set back to true to disarm.
DRY_RUN=false

log() { printf '[herd.restore hook] %s\n' "$*"; }

# ── Locate the restore core (herd-restore) to source ──────────────────────
# Deployed canonical location is ~/.local/bin/herd-restore. Fall back to a
# repo-relative sibling (../herd-restore from this plugin dir) for the linked
# dev checkout where the plugin lives at bin/herdr-restore-plugin/.
find_core() {
  local candidates=(
    "$HOME/.local/bin/herd-restore"
    "${HERDR_PLUGIN_ROOT:-$PWD}/../herd-restore"
  )
  local c
  for c in "${candidates[@]}"; do
    [ -f "$c" ] && { printf '%s\n' "$c"; return 0; }
  done
  return 1
}

# ── Resolve the manifest from the plugin state dir ────────────────────────
STATE_DIR="${HERDR_PLUGIN_STATE_DIR:-}"
if [ -z "$STATE_DIR" ]; then
  log "HERDR_PLUGIN_STATE_DIR is unset — not running inside a Herdr startup hook?"
  log "Nothing to do; exiting 0 (a startup failure must not stall the server)."
  exit 0
fi

MANIFEST="$STATE_DIR/restore.tsv"
if [ ! -s "$MANIFEST" ]; then
  log "No pinned sessions at $MANIFEST — nothing to restore."
  exit 0
fi

CORE="$(find_core)" || {
  log "Could not find herd-restore core to source (looked in ~/.local/bin and the"
  log "plugin's sibling dir). Cannot rebuild; exiting 0."
  exit 0
}

log "event=${HERDR_PLUGIN_EVENT:-?} manifest=$MANIFEST core=$CORE dry_run=$DRY_RUN"

# ── Source the core and drive its dry-run reconcile ───────────────────────
# herd-restore guards `main` behind BASH_SOURCE==$0, so sourcing exposes
# reconcile_bare_shells / herd_restore_one WITHOUT running the manual wrapper.
# The core reads $MANIFEST and honours $DRY_RUN + $SESSIONS_DIR.
export HERD_RESTORE_MANIFEST="$MANIFEST"   # keep the core's own default in sync
export DRY_RUN
# shellcheck source=/dev/null
source "$CORE"
# After sourcing, the core's own MANIFEST is seeded from HERD_RESTORE_MANIFEST
# (exported above), so reconcile_bare_shells reads the state-dir manifest.

# WS-4 redesign: reconcile against SETTLED pane state (wait for Herdr's replay
# to finish, then fill only bare-shell panes by resuming INTO them) rather than
# racing the replay with a fixed sleep. See the core's reconcile_bare_shells.
if reconcile_bare_shells; then
  log "reconcile complete (dry_run=$DRY_RUN) — all pinned sessions accounted for."
else
  log "reconcile reported issues above (missing session file, ambiguous cwd, etc.; dry_run=$DRY_RUN)."
fi
