---
name: research
description: Investigate a question against high-trust primary sources and capture the findings as a Markdown file. Use when the user wants a topic researched, docs or API facts gathered, or reading legwork delegated.
---

Spin up a **background agent** (sub-agent) to do the research, so you keep working while it reads.

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
