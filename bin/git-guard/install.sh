#!/usr/bin/env bash
# git-guard :: install.sh
#
# Installs the git-guard hooks as a GLOBAL git hooksPath, so protected-branch and
# force-push protection applies to EVERY repo on this machine at once — including
# every repo an agent or sub-agent operates in via a `shell` tool. The enforcement
# lives in git itself, not in an agent prompt, which is the whole point: a model
# cannot route a `git push`/`git commit` around a hook that git runs for it.
#
# Idempotent. Safe to re-run (e.g. from setup.sh on every sync).
#
# What it does:
#   1. Copies bin/git-guard/hooks/* into ~/.config/git-guard/hooks (the live dir).
#   2. Points `git config --global core.hooksPath` at that dir.
#
# Caveat it handles: a global core.hooksPath REPLACES a repo's own .git/hooks. The
# guard hooks therefore chain to `<hook>.local` in the same dir if present, and this
# installer preserves an already-set global hooksPath's hooks by copying them in as
# `.local` so they still fire. A repo that relies on committed .git/hooks (rare) can
# re-point locally with `git config core.hooksPath .git/hooks`.

set -euo pipefail

SRC_DIR="$(cd "$(dirname "$0")" && pwd)/hooks"
LIVE_DIR="${GIT_GUARD_DIR:-$HOME/.config/git-guard/hooks}"

if [ ! -d "$SRC_DIR" ]; then
  echo "git-guard: source hooks dir not found at $SRC_DIR" >&2
  exit 1
fi

mkdir -p "$LIVE_DIR"

# Preserve an existing DIFFERENT global hooksPath's hooks by chaining them as .local
# (only if it isn't already our live dir, and only for the hooks we manage).
existing_path="$(git config --global --get core.hooksPath || true)"
if [ -n "$existing_path" ] && [ "$existing_path" != "$LIVE_DIR" ]; then
  for hook in pre-push pre-commit; do
    if [ -x "$existing_path/$hook" ] && [ ! -e "$LIVE_DIR/$hook.local" ]; then
      cp "$existing_path/$hook" "$LIVE_DIR/$hook.local"
      chmod +x "$LIVE_DIR/$hook.local"
      echo "  ↪ chained existing global $hook → $hook.local"
    fi
  done
fi

# Install our managed hooks.
count=0
for hook in "$SRC_DIR"/*; do
  [ -f "$hook" ] || continue
  name="$(basename "$hook")"
  cp "$hook" "$LIVE_DIR/$name"
  chmod +x "$LIVE_DIR/$name"
  count=$((count + 1))
done

git config --global core.hooksPath "$LIVE_DIR"

echo "  ✓ git-guard installed: $count hook(s) → $LIVE_DIR"
echo "    global core.hooksPath = $LIVE_DIR"
echo "    protected branches   = ${GIT_GUARD_PROTECTED_BRANCHES:-main master develop qa}"
