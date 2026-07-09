# Release Notes (Non-Technical)

Use when generating release notes for a non-technical audience (stakeholders, product owners, end users).

## Trigger

User asks for "user-facing release notes", "stakeholder update", "what's new summary", or explicitly says "non-technical".

## Process

1. Get the same PR/commit list as the technical release notes
2. Filter out anything invisible to users (refactors, test changes, CI, dependency bumps)
3. Rewrite remaining items in plain language — focus on **what changed for the user**, not how
4. Group by user impact, not code category

## Categories

| Section | What goes here |
|---------|---------------|
| ✨ What's New | New features or capabilities users can now do |
| 🔧 Improvements | Things that work better than before (speed, UX, reliability) |
| 🐛 Fixed | Bugs that were affecting users, now resolved |
| ⚠️ Known Issues | Things still being worked on (optional, if relevant) |

## Writing Style

- No jargon: say "the page loads faster" not "optimised SSR hydration"
- No code references, PR numbers, or technical terms
- Write from the user's perspective: "You can now..." or "Fixed an issue where..."
- One sentence per item, plain English
- Present tense for new features, past tense for fixes

## Output Format

```markdown
# What's New — [Product Name] [Date or Version]

## ✨ What's New
- You can now [do something new]. 
- [Feature] is now available on [platform/page].

## 🔧 Improvements
- [Page/feature] now loads faster.
- [Action] is now more reliable on slow connections.

## 🐛 Fixed
- Fixed an issue where [problem users experienced].
- [Feature] no longer [undesired behaviour].
```

## Rules

- If a release has no user-visible changes, say so: "This release contains behind-the-scenes improvements. No user-facing changes."
- Keep it short — aim for 5-10 bullet points max even for big releases
- Don't explain the "why" unless it helps the reader understand what changed
- If unsure whether something is user-visible, ask
