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
- Move product steering to per-repo `.kiro/steering/` (CLI loads on demand when `cd`-ing into a repo)
- Reduce model-invoked skill descriptions to single-line summaries
- Move knowledge bases to on-demand reads (remove auto-loading)

### Tier 3 — Significant restructuring
- Split skills into "core" (always loaded: build-verify, commit-messages, code-review) and "extended" (loaded by trigger keyword only)
- Replace steering prose with structured YAML/JSON (denser, less readable)
- Consolidate the two product steering files into one with a product selector key

### Current overhead estimate
| Component | ~Tokens | % of 128k |
|-----------|---------|-----------|
| Steering docs (5) | ~2,000 | 1.6% |
| Skill descriptions (25) | ~1,500 | 1.2% |
| Knowledge bases (auto-loaded) | ~500 | 0.4% |
| System prompt + tool schemas | ~15,000 | 11.7% |
| **Total fixed overhead** | **~19,000** | **~15%** |

The system prompt and tool schemas are the largest fixed cost and aren't under our control. Steering + skills are small — only worth compressing if limits drop below 64k.
