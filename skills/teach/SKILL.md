---
name: teach
description: Teach the user a new skill or concept over multiple sessions, using the current directory as a stateful teaching workspace. Use when the user wants to learn something new.
argument-hint: What would you like to learn about?
---

# Teach

The user wants to learn something. This is stateful — they intend to learn over multiple sessions.

## Teaching Workspace

Use the current directory as a teaching workspace. State is captured in:

- `MISSION.md` — Why the user is learning this. Grounds all teaching.
- `RESOURCES.md` — High-quality external resources (articles, docs, videos, courses).
- `./reference/*.html` — Compressed learnings: cheat sheets, glossaries, syntax references. Designed for quick lookup. Beautiful, printable.
- `./learning-records/*.md` — What the user has learned. Titled `0001-<name>.md`. Captures non-obvious insights and key takeaways. Used to calculate zone of proximal development.
- `./lessons/*.html` — Self-contained HTML lessons. One tightly-scoped concept per file. Titled `0001-<name>.html`.
- `./assets/*` — Reusable components shared across lessons (stylesheets, quiz widgets, diagrams).
- `NOTES.md` — User preferences and working notes.

## Philosophy

Deep learning requires:
- **Knowledge** — from high-quality, trusted resources (never parametric knowledge alone)
- **Skills** — acquired through interactive lessons with tight feedback loops
- **Wisdom** — from real-world application and community

### Storage Strength > Fluency

Prioritise long-term retention over in-the-moment recall:
- Retrieval practice (recall from memory)
- Spacing (distribute practice over time)
- Interleaving (mix related topics in practice)

## Process

### First Session
1. If `MISSION.md` doesn't exist, question the user on *why* they want to learn this
2. Create `MISSION.md`
3. Find high-quality resources → populate `RESOURCES.md`
4. Produce the first lesson

### Subsequent Sessions
1. Read `learning-records/` to understand current level
2. Determine zone of proximal development
3. Produce the next lesson — one tangible win, directly tied to the mission

## Lessons

Each lesson is one self-contained HTML file:
- Clean, readable typography (think Tufte)
- Short and completable quickly — respect working memory limits
- Teach knowledge first, then practice the skill
- Include citations and links to resources
- Link to other lessons and reference docs via HTML anchors
- Recommend one primary source to read/watch
- End with a reminder to ask followup questions
- Open the file for the user after writing (`open <path>` on macOS)

## Reference Documents

Create alongside lessons. Designed for repeated quick lookup:
- Glossaries
- Syntax/code snippets
- Algorithms and flowcharts
- Key patterns and their trade-offs

## Learning Records

After each session where meaningful learning occurred, create a learning record:
- What was learned
- Key insight (non-obvious)
- Connection to mission
- What to explore next
