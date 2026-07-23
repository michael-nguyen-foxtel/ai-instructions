---
name: research
description: Investigate a question against high-trust primary sources and capture the findings as a Markdown file. Use when the user wants a topic researched, docs or API facts gathered, or reading legwork delegated.
---

Spin up a **background agent** (sub-agent) to do the research, so you keep working while it reads.

## Tool Selection

When looking things up externally, pick the right tool:

| Need | Tool | Examples |
|------|------|----------|
| API signatures, method params, code examples, library usage patterns | **Context7** (`resolve-library-id` → `query-docs`) | "How does Braze `addAlias` work?", "React Router v7 loader API", "Webpack 5 module federation config" |
| Infrastructure URLs, breaking change confirmations, ecosystem facts, error diagnosis | **Web search** | "What's the Braze CDN endpoint?", "Did Next.js 15 drop pages router?", "AWS ALB 502 causes" |
| First-party source code, changelogs, GitHub issues | **Web search** (to find) then **web_fetch** (to read) | Finding a specific GitHub issue or changelog entry |

**Default to Context7 first** when the question is about a library's API — it returns verified docs with code snippets. Fall back to web search only if Context7 has no coverage or the question is about infrastructure/URLs/ecosystem facts rather than "how do I use this API?".

Its job:

1. Investigate the question against **primary sources** — official docs, source code, specs, first-party APIs — not secondary write-ups of them. Follow every claim back to the source that owns it.
2. Write the findings to a single Markdown file, citing each claim's source with a URL or file path.
3. Save it where the repo already keeps such notes (e.g. `docs/research/`); match the existing convention. If none exists, use `docs/research/` and say where it went.

## Output format

```markdown
# Research: [Question]

Date: [YYYY-MM-DD]

## Summary

[2-3 sentence answer to the question]

## Findings

### [Sub-topic]

[Finding with citation]

Source: [URL or file path]

## Open Questions

- [Anything that couldn't be resolved from primary sources]
```
