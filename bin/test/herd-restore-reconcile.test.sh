#!/usr/bin/env bash
# herd-restore-reconcile.test.sh — unit tests for the resume-into-bare-shells
# reconciliation core in bin/herd-restore.
#
# Spec: .kiro/specs/ws4-resume-into-bare-shells-SPEC.md
#
# Strategy: source the core (its `main` is guarded behind BASH_SOURCE==$0), stub
# `herdr` via a fake function that emits canned `pane list` JSON, point
# SESSIONS_DIR and MANIFEST at temp fixtures, run in DRY_RUN, and assert on the
# emitted actions. No real Herdr, no network, no restart needed.
#
# Run: bash bin/test/herd-restore-reconcile.test.sh

set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE="$HERE/../herd-restore"

PASS=0
FAIL=0
pass() { PASS=$(( PASS + 1 )); printf '  ok   %s\n' "$1"; }
fail() { FAIL=$(( FAIL + 1 )); printf '  FAIL %s\n       %s\n' "$1" "${2:-}"; }

assert_contains() { # haystack needle label
  if printf '%s' "$1" | grep -qFe "$2"; then pass "$3"; else fail "$3" "expected to find: $2"; fi
}
assert_not_contains() { # haystack needle label
  if printf '%s' "$1" | grep -qFe "$2"; then fail "$3" "did NOT expect: $2"; else pass "$3"; fi
}

# ── Fixtures ──────────────────────────────────────────────────────────────
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export KIRO_SESSIONS_DIR="$TMP/sessions"
mkdir -p "$KIRO_SESSIONS_DIR"
for sid in aaaaaaaa-0000-0000-0000-000000000001 \
           bbbbbbbb-0000-0000-0000-000000000002 \
           cccccccc-0000-0000-0000-000000000003 \
           dddddddd-0000-0000-0000-000000000004; do
  echo '{}' > "$KIRO_SESSIONS_DIR/$sid.json"
done

# Fake `herdr`: `pane list` emits JSON from $FAKE_PANES (a ; -separated list of
# `pane_id,agent,cwd` triples; empty agent = bare shell). Other subcommands are
# no-op successes.
FAKE_PANES=""
herdr() {
  if [ "${1:-}" = "pane" ] && [ "${2:-}" = "list" ]; then
    printf '{"result":{"type":"pane_list","panes":['
    local first=1 triple pid agent cwd rest
    local IFS=';'
    for triple in $FAKE_PANES; do
      [ -n "$triple" ] || continue
      pid="${triple%%,*}"; rest="${triple#*,}"
      agent="${rest%%,*}"; cwd="${rest#*,}"
      [ "$first" = 1 ] || printf ','
      first=0
      if [ -n "$agent" ]; then
        printf '{"pane_id":"%s","agent":"%s","cwd":"%s"}' "$pid" "$agent" "$cwd"
      else
        printf '{"pane_id":"%s","cwd":"%s"}' "$pid" "$cwd"
      fi
    done
    printf ']}}\n'
    return 0
  fi
  return 0
}
export -f herdr

# Near-instant settle in tests.
export HERD_RESTORE_SETTLE_STABLE_READS=2
export HERD_RESTORE_SETTLE_POLL_SEC=0.05
export HERD_RESTORE_SETTLE_CEILING_SEC=2
export DRY_RUN=true

export HERD_RESTORE_MANIFEST="$TMP/dummy.tsv"; : > "$HERD_RESTORE_MANIFEST"
# shellcheck source=/dev/null
source "$CORE"

write_manifest() { printf '%b' "$1" > "$TMP/manifest.tsv"; MANIFEST="$TMP/manifest.tsv"; }

echo "panes_snapshot + matching"
FAKE_PANES="wA:p1,kiro,/repo/live;wB:p1,,/repo/bare"
SNAP="$(panes_snapshot)"
assert_contains "$SNAP" "wB:p1"$'\t'$'\t'"/repo/bare" "snapshot marks bare shell (empty agent)"
assert_contains "$SNAP" "wA:p1"$'\t'"kiro"$'\t'"/repo/live" "snapshot marks live kiro pane"
assert_contains "$(bare_shell_pane_for_cwd "$SNAP" /repo/bare)" "wB:p1" "unique bare shell matched by cwd"
assert_not_contains "$(bare_shell_pane_for_cwd "$SNAP" /repo/live)" "wA:p1" "live pane is NOT a bare-shell match"

echo "ambiguity: two bare shells same cwd -> no match"
FAKE_PANES="wB:p1,,/repo/dup;wC:p1,,/repo/dup"
SNAP="$(panes_snapshot)"
GOT="$(bare_shell_pane_for_cwd "$SNAP" /repo/dup | tr -d '[:space:]')"
if [ -z "$GOT" ]; then pass "ambiguous cwd yields empty (no guess)"; else fail "ambiguous cwd yields empty" "got: $GOT"; fi

echo "Case (a): live kiro pane at cwd -> skip"
FAKE_PANES="wA:p1,kiro,/repo/live"
write_manifest "sessA\taaaaaaaa-0000-0000-0000-000000000001\t/repo/live\n"
OUT="$(reconcile_bare_shells 2>&1)"
assert_contains "$OUT" "skip" "live pane -> skip"
assert_not_contains "$OUT" "agent start sessA" "live pane -> no resume attempted"

echo "Case (b): bare shell at cwd -> resume INTO pane"
FAKE_PANES="wB:p1,,/repo/bare"
write_manifest "sessB\tbbbbbbbb-0000-0000-0000-000000000002\t/repo/bare\n"
OUT="$(reconcile_bare_shells 2>&1)"
assert_contains "$OUT" "--pane wB:p1 -- chat --resume-id bbbbbbbb-0000-0000-0000-000000000002" "bare shell -> resume-into-pane wB:p1"
assert_not_contains "$OUT" "workspace create" "bare shell -> NO fresh workspace"

echo "Case (c): no pane at cwd -> fresh workspace fallback"
FAKE_PANES="wZ:p1,kiro,/repo/somewhere-else"
write_manifest "sessC\tcccccccc-0000-0000-0000-000000000003\t/repo/missing\n"
OUT="$(reconcile_bare_shells 2>&1)"
assert_contains "$OUT" "fresh workspace" "no pane -> fresh workspace path"
assert_contains "$OUT" "workspace create --cwd /repo/missing" "fresh workspace uses the pin cwd"

echo "Case (d): two pins share a cwd -> superseded skipped, owner acted on (fix a)"
# Owner is the live pin. We designate liveness deterministically via
# KIRO_SESSION_ID (owner_id_for_cwd treats own-session as live), avoiding a real
# lock file. sessD2's id == KIRO_SESSION_ID => sessD2 owns /repo/shared.
FAKE_PANES="wB:p1,,/repo/shared"
write_manifest "sessD1\tdddddddd-0000-0000-0000-000000000004\t/repo/shared\nsessD2\taaaaaaaa-0000-0000-0000-000000000001\t/repo/shared\n"
OUT="$(KIRO_SESSION_ID=aaaaaaaa-0000-0000-0000-000000000001 reconcile_bare_shells 2>&1)"
assert_contains "$OUT" "superseded" "shared cwd -> non-owner (sessD1) skipped as superseded"
assert_not_contains "$OUT" "resume-id dddddddd" "superseded pin -> no resume attempted"
# The owner (sessD2/aaaa) is NOT its own live pane here (it's own-session, not a
# kiro pane in the snapshot), so it should resume INTO the bare shell wB:p1.
assert_contains "$OUT" "--pane wB:p1 -- chat --resume-id aaaaaaaa-0000-0000-0000-000000000001" "owner resumes into the shared bare shell"

echo "Case (d2): dead pin no longer strands the live owner (restart #2 scenario)"
# Live owner already has a LIVE kiro pane at the cwd; the dead pin must be
# skipped as superseded, and the owner skipped as already-live — NEITHER rebuilt.
FAKE_PANES="wC:p1,kiro,/repo/ai"
write_manifest "hqdead\tdddddddd-0000-0000-0000-000000000004\t/repo/ai\nhqlive\taaaaaaaa-0000-0000-0000-000000000001\t/repo/ai\n"
OUT="$(KIRO_SESSION_ID=aaaaaaaa-0000-0000-0000-000000000001 reconcile_bare_shells 2>&1)"
assert_contains "$OUT" "superseded" "dead pin skipped as superseded"
assert_contains "$OUT" "already serves /repo/ai" "live owner skipped (already served)"
assert_not_contains "$OUT" "workspace create" "restart-#2 scenario -> no rebuild of anything"
assert_not_contains "$OUT" "resume-id dddddddd" "dead pin never resumed"

echo "Case (f): idempotent re-run (all live) -> no-op"
FAKE_PANES="wB:p1,kiro,/repo/bare"
write_manifest "sessB\tbbbbbbbb-0000-0000-0000-000000000002\t/repo/bare\n"
OUT="$(reconcile_bare_shells 2>&1)"
assert_contains "$OUT" "skip" "re-run after fill -> skip (no-op)"
assert_not_contains "$OUT" "resume-id" "re-run -> no resume attempted"

echo "Case (e): settle waits until the pin is ACCOUNTED-FOR, not on early quiet (fix c)"
# Simulate a slow, staggered replay: the first N reads show NO pane at the pin's
# cwd (empty and 'stable'), then the pane appears. A stability-only settle would
# have returned early on the empty-but-stable snapshot; accounted-for must wait.
COUNTER_FILE="$TMP/read_count"; echo 0 > "$COUNTER_FILE"
herdr() {
  if [ "${1:-}" = "pane" ] && [ "${2:-}" = "list" ]; then
    local n; n=$(cat "$COUNTER_FILE"); echo $(( n + 1 )) > "$COUNTER_FILE"
    if [ "$n" -lt 3 ]; then
      # Early reads: an unrelated pane elsewhere; nothing at /repo/slow.
      printf '{"result":{"panes":[{"pane_id":"wX:p1","cwd":"/repo/other"}]}}\n'
    else
      printf '{"result":{"panes":[{"pane_id":"wS:p1","cwd":"/repo/slow"}]}}\n'
    fi
    return 0
  fi
  return 0
}
export -f herdr
echo '{}' > "$KIRO_SESSIONS_DIR/eeeeeeee-0000-0000-0000-000000000005.json"
write_manifest "sessE\teeeeeeee-0000-0000-0000-000000000005\t/repo/slow\n"
SETTLED="$(wait_for_pane_settle)"
assert_contains "$SETTLED" "wS:p1"$'\t'$'\t'"/repo/slow" "settle waited for the late pane (accounted-for)"
READS=$(cat "$COUNTER_FILE")
if [ "$READS" -ge 4 ]; then pass "settle polled past the early-stable window ($READS reads)"; else fail "settle polled past early-stable" "only $READS reads"; fi
# Restore the simple fake for any later cases.
herdr() {
  if [ "${1:-}" = "pane" ] && [ "${2:-}" = "list" ]; then
    printf '{"result":{"panes":[]}}\n'; return 0
  fi
  return 0
}
export -f herdr

echo ""
echo "------------------------------------------"
echo "PASS: $PASS   FAIL: $FAIL"
[ "$FAIL" -eq 0 ]
