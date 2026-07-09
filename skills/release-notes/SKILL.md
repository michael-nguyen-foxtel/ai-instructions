# Release Notes (Technical)

Use when generating release notes for a technical audience (developers, QA, other engineers).

## Trigger

User asks to "generate release notes", "write changelog", "summarise changes since last release", or mentions a release/tag.

## Process

1. Identify the version range (e.g., last tag to HEAD, or two specified tags/commits)
2. Gather all merged PRs in that range
3. Categorise each PR by type
4. Write concise summaries with PR links

## Categories (in order)

| Emoji | Category | Description |
|-------|----------|-------------|
| 🚀 | Features | New user-facing functionality |
| 🐛 | Bug Fixes | Corrections to existing behaviour |
| ⚡ | Performance | Speed or resource improvements |
| ♻️ | Refactors | Code changes with no behaviour change |
| 🔒 | Security | Vulnerability fixes or hardening |
| 📦 | Dependencies | Dependency updates |
| 🧪 | Tests | New or improved tests |
| 🏗️ | Infrastructure | CI/CD, build, deploy changes |
| 📝 | Documentation | Doc updates |

## Output Format

```markdown
# [Repo Name] v[X.Y.Z] — [Date]

## 🚀 Features
- Brief description of change ([#PR](link)) — @author

## 🐛 Bug Fixes
- Brief description of fix ([#PR](link)) — @author

## ⚡ Performance
- ...

## 📦 Dependencies
- Bump [package] from X to Y ([#PR](link))

---

**Full diff**: [compare link]
**Contributors**: @person1, @person2
```

## Rules

- One line per PR, max ~80 chars for the description
- Always include the PR number as a link
- Include the author (@github-handle)
- Skip merge commits and bot PRs (dependabot) unless they're security-relevant
- If a PR touches multiple categories, pick the primary one
- Order within category: most impactful first
- Omit empty categories
