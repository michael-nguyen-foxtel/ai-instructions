# Dependency Check

Use when evaluating whether to add a new package or reviewing existing dependencies.

## Trigger

User asks to "check a package", "should I use X?", "evaluate dependency", or is about to install something new.

## Evaluation Criteria

For each package, assess:

### 1. Maintenance Health
- Last publish date (red flag if > 12 months)
- Open issues vs. closed ratio
- Active maintainers (bus factor)
- Responds to security issues promptly?

### 2. Security
- Known vulnerabilities (check npm audit, Snyk, GitHub advisories)
- Dependency tree depth (deep trees = more attack surface)
- Does it request unusual permissions or run postinstall scripts?

### 3. Bundle Impact
- Package size (bundlephobia.com equivalent assessment)
- Tree-shakeable?
- Does it pull in large transitive dependencies?
- Compare with lighter alternatives

### 4. Compatibility
- Supports your Node version (check .nvmrc — currently v20)
- Works with your build tool (webpack)
- ESM/CJS compatibility with your setup
- React version compatibility if it's a React package

### 5. License
- Compatible with your project? (MIT, Apache 2.0 = good; GPL = check with team)
- Any license changes in recent versions?

### 6. Alternatives
- Is there a native browser/Node API that does this?
- Could you write this in < 50 lines without the dep?
- Are there lighter or more maintained alternatives?

## Output Format

```
📦 Package: [name]@[version]

✅ Pros:
- ...

⚠️ Concerns:
- ...

📊 Stats:
- Weekly downloads: X
- Last published: X
- Bundle size: X (gzipped)
- Dependencies: X
- License: X

🏆 Verdict: RECOMMEND / CAUTION / AVOID
💡 Alternative: [if applicable]
```

## Red Flags (auto-reject unless justified)

- No TypeScript types (or @types/ package) when working in TS repos
- Fewer than 100 weekly downloads (potential typosquatting)
- Postinstall scripts that download binaries
- Unmaintained (no commits in 2+ years, unresolved critical issues)
- License incompatibility
