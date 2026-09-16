#!/usr/bin/env bash
# git-guard hook tests. Self-contained: builds throwaway repos in $TMPDIR and
# invokes the hooks the way git does (args + stdin ref lines). Touches NO global
# git config. Run: bash bin/test/git-guard.test.sh
set -uo pipefail

GG="$(cd "$(dirname "$0")/../git-guard" && pwd)"
pass=0; fail=0
ok()   { echo "✅ $1"; pass=$((pass+1)); }
bad()  { echo "❌ $1"; fail=$((fail+1)); }
run()  { bash "$GG/hooks/$1" "${@:2}"; }
ZERO=0000000000000000000000000000000000000000

# --- syntax ---
for f in hooks/pre-push hooks/pre-commit install.sh; do
  bash -n "$GG/$f" || bad "syntax: $f"
done

TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
git init -q -b main "$TMP/bare.git" --bare
git init -q "$TMP/work"; cd "$TMP/work"
git config user.email t@t.io; git config user.name t; git config commit.gpgsign false
git remote add origin "$TMP/bare.git"
echo one > f; git add f; git commit -qm init; git push -q -u origin main

# 1 pre-commit blocks on main
echo x >> f; git add f
run pre-commit 2>/dev/null && bad "commit on main allowed" || ok "commit on main blocked"
git reset -q HEAD f

# 2 pre-commit allows on feature branch
git checkout -q -b feat/x; echo y >> f; git add f
run pre-commit 2>/dev/null && ok "commit on feature allowed" || bad "commit on feature blocked"
git reset -q HEAD f; git checkout -q main

# 3 pre-commit override
echo z >> f; git add f
GIT_GUARD_ALLOW=1 run pre-commit 2>/dev/null && ok "commit override allowed" || bad "commit override blocked"
git reset -q HEAD f

L=$(git rev-parse HEAD)
# 4 pre-push blocks protected
printf 'refs/heads/main %s refs/heads/main %s\n' "$L" "$ZERO" | run pre-push origin "$TMP/bare.git" 2>/dev/null \
  && bad "push to main allowed" || ok "push to main blocked"

# 5 pre-push allows feature ff (new branch, remote sha = 0)
printf 'refs/heads/feat/x %s refs/heads/feat/x %s\n' "$L" "$ZERO" | run pre-push origin "$TMP/bare.git" 2>/dev/null \
  && ok "push new feature allowed" || bad "push new feature blocked"

# 6 pre-push blocks force (non-ff) to a NON-protected branch
git checkout -q -b feat/f; echo a > g; git add g; git commit -qm A; R=$(git rev-parse HEAD)
git commit -q --amend -m A2; F=$(git rev-parse HEAD)
printf 'refs/heads/feat/f %s refs/heads/feat/f %s\n' "$F" "$R" | run pre-push origin "$TMP/bare.git" 2>/dev/null \
  && bad "force-push allowed" || ok "force-push blocked"

# 7 force-push override
printf 'refs/heads/feat/f %s refs/heads/feat/f %s\n' "$F" "$R" | GIT_GUARD_ALLOW=1 run pre-push origin "$TMP/bare.git" 2>/dev/null \
  && ok "force-push override allowed" || bad "force-push override blocked"

# 8 genuine fast-forward update allowed
echo b >> g; git add g; git commit -qm B; F2=$(git rev-parse HEAD)
printf 'refs/heads/feat/f %s refs/heads/feat/f %s\n' "$F2" "$F" | run pre-push origin "$TMP/bare.git" 2>/dev/null \
  && ok "fast-forward update allowed" || bad "fast-forward update blocked"

# 9 chaining: .local runs first and can veto
LIVE=$(mktemp -d)
cp "$GG/hooks/pre-commit" "$LIVE/pre-commit"; chmod +x "$LIVE/pre-commit"
printf '#!/usr/bin/env bash\necho local-ran >&2\nexit 3\n' > "$LIVE/pre-commit.local"; chmod +x "$LIVE/pre-commit.local"
git checkout -q -b feat/chain
if bash "$LIVE/pre-commit" 2>"$TMP/chain.err"; then bad "chained veto ignored"
else grep -q local-ran "$TMP/chain.err" && ok "chained .local ran first and vetoed" || bad "chained .local did not run"; fi

echo ""
echo "git-guard: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
