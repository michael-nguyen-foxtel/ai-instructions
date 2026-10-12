# Token Efficiency

Rules to minimise context waste. Follow these in every session.

## Hard Rules

1. **Never read full lockfiles** — `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`. Use `git diff --stat` or `grep` for specific entries.
2. **`git diff --stat` before `git diff`** — preview what changed before pulling full diffs. Only read full diffs for files you need to understand.
3. **Cap large file reads** — if a file is 300+ lines and you only need a section, use offset/limit or the `code` tool for symbol lookup first.
4. **Never search or list inside `node_modules/`, `dist/`, or build output** — exclude these from `grep`, `glob`, `find`, and directory listings. The only exception is when the task explicitly requires inspecting an installed package (e.g., debugging a dependency's source or checking its exports).
5. **Prefer `code` tool symbol search over full file reads** — when looking for a specific function, class, or export.

## Patterns

### Git operations
```
✗ git_diff_unstaged (can return entire deleted files)
✓ git_status → git diff --stat → targeted git diff on specific files
```

### File reads
```
✗ Read 400-line file to find one function
✓ code tool → search_symbols("functionName") → read only the relevant lines
```

### Handoffs
```
✗ Re-read entire spec at start of new session
✓ Read handoff doc first — only read spec sections if handoff is insufficient
```

## Future-Proofing: If Context Window Shrinks

If token limits reduce, apply these changes in order (least disruptive first):

### Tier 1 — Low effort, no behaviour change
- Compress steering doc prose (remove examples, keep tables)
- Remove the "Gotchas" and "Key Seams" sections from product steering (keep env maps and repo tables)
- Trim testing-conventions to just the rules (remove the examples and anti-patterns)

### Tier 2 — Moderate effort, minor behaviour change
- Move product steering to per-repo `.kiro/steering/` (CLI loads on demand when `cd`-ing
  into a repo), saving ~1.9k always-on on non-product sessions. **Caveat (measured
  2026-10-12):** the product repos (magneto-*, hawk-*) ALREADY carry their own
  `.kiro/steering/` with `product.md`, `domain.md`, `tech.md`, etc. So this is a
  *reconcile/merge* of the global `product-hubbl.md` / `product-watchafl-watchnrl.md`
  into each repo's existing `product.md`, one repo at a time — NOT a clean `git mv`, or
  you create two drifting product docs per repo. Also resolve first: `.kiro` is gitignored
  in the widgets repos (local-only, won't survive a clone) but committed in the
  web-server repos — so "repo-level" is only durable in two of the four.
- Reduce model-invoked skill descriptions to single-line summaries
- Move knowledge bases to on-demand reads (remove auto-loading)

### Tier 3 — Significant restructuring
- Split skills into "core" (always loaded: build-verify, commit-messages, code-review) and "extended" (loaded by trigger keyword only)
- Replace steering prose with structured YAML/JSON (denser, less readable)
- Consolidate the two product steering files into one with a product selector key

### Current overhead estimate
Measured 2026-10-12 (steering by `wc -w` × 1.3; schemas estimated, host-injected).

| Component | ~Tokens | % of 128k |
|-----------|---------|-----------|
| Steering docs (14) | ~14,400 | 11.3% |
| MCP tool schemas (Fallow, Atlassian, Playwright, git, …) | ~15,000 | 11.7% |
| Skill descriptions (~33) | ~1,500 | 1.2% |
| Knowledge bases (pointer only; bodies load on demand) | ~400 | 0.3% |
| **Total fixed overhead** | **~31,000** | **~24%** |

The two big always-on costs are MCP tool schemas (~15k, injected per turn whether used
or not — trim by disabling unused MCP servers in a session, not by writing more) and
steering (~14.4k, fully under our control). Steering has grown ~7x since the first
estimate — the largest single docs are `task-routing` (~3.7k), `herdr` (~1.9k),
`output-style` (~1.4k), and the two product docs (~1.9k combined). Building MCP servers
*raises* always-on cost (a schema is as always-on as steering); it buys typed tools and
safety boundaries, not a smaller window.
