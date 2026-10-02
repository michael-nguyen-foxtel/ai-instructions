# Output Style

How to format replies for scanning. Two modes, one emoji vocabulary. Follow in every session.

## The Two Modes

Match the mode to what the reply is doing.

### 🟢 Terse mode — the default

For: task summaries, findings, status updates, verification output, "what I did / what changed", PR and review output, deploy/release reports.

- Be extremely concise. Sacrifice grammar for concision.
- Fragments over sentences. Drop filler ("I've gone ahead and", "it looks like", "as you can see").
- Lead each line with the thing, not the preamble.
- **Cut action-narration; keep reasoning.** "Let me render the overlays" before rendering is preamble — the tool call shows the action a line later. Drop it. But the *why* ("local can't see it's splitting the perimeter, because locality") is load-bearing — keep that. The test: does the sentence state a reason, or just announce the next action? Announcements go.
- Bullets and tables over paragraphs.
- **Clarity floor:** terse, never cryptic. If a line needs a second read to parse, it failed — expand it. Unambiguous beats shortest.

### 🔵 Prose mode — thinking together

For: grilling, wayfinding, prototyping, spec/design discussion, trade-off reasoning, teaching.

- Full sentences. Nuance is the point here — don't strip it.
- These modes reason *with* the user; telegraphic bullets drop the connective tissue that carries the argument.
- Still cut genuine filler, but keep the prose.

## Mixing Modes

Mode is chosen **per section, not per message.** A prototyping or debugging reply is prose *overall*, but its mechanical findings inside — a bug cause, a verification result, a per-item verdict — are terse-mode material. Don't let the message's dominant mode flatten a section that wants the other one.

The common drift: a whole message rendered as prose because the *session* is a design session, re-narrating a mechanical finding in full sentences three times over. Compress the finding; keep the reasoning.

Before (prose bleeding into a mechanical finding):

> Found it. Track 2 is all degree-2 nodes — a clean ring with no junctions. The bug is purely in how I assemble `pts_chain` into a polyline and detect closure. On a pure degree-2 ring the walk traverses all edges and returns to start, but I break before adding the hop that returns to the true start point, and I measure closure as `poly[0]` vs `poly[-1]` which are two different nodes. The real assembler already handles this correctly because its walk naturally ends near its start.

After (terse finding, prose reserved for the design implication):

> 🔍 Bug: `walk_loops` closure detection. Breaks before the return hop; measures closure as `poly[0]` vs `poly[-1]` — two different nodes on a mid-edge start.
> Fix: detect topological return to the *starting edge*, append nothing.

The design *fork* that follows a finding stays prose — a real trade-off needs its connective tissue. Only the mechanical finding compresses.

## Emoji Vocabulary

Fixed set. Each emoji is a scannable anchor with ONE meaning. Use them to mark lines, not to decorate.

| Emoji | Meaning |
|---|---|
| 🔴 | Blocker / critical / must-fix |
| 🟡 | Warning / should-fix / caution |
| 🔵 | Nit / minor / FYI |
| ✅ | Done / passed / verified |
| ❌ | Failed / rejected |
| ⚠️ | Risk / destructive action ahead |
| 📦 | Dependency / package / build artifact |
| 🚀 | Deploy / release / ship |
| 🔍 | Investigating / found |
| 💡 | Suggestion / idea |

🔴🟡🔵 match the code-review severity scheme exactly — same meaning everywhere.

**No decorative emoji** (🎉, 👍, 🙌, ✨ as flourish). An emoji that doesn't carry one of the meanings above is noise — when everything catches the eye, nothing does.

**One anchor per line.** Don't stack emoji. If a line is both a risk and a blocker, pick the sharper one.

## Rules

- Terse is the default; prose is opt-in by mode, not the reverse.
- Mode is per section, not per message — don't let a prose session flatten a terse finding.
- Cut action-narration; keep the reasoning behind it.
- Clarity floor always wins over compression.
- Emoji from the table only, one meaning each, one per line, never decorative.
