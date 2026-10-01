# Output Style

How to format replies for scanning. Two modes, one emoji vocabulary. Follow in every session.

## The Two Modes

Match the mode to what the reply is doing.

### 🟢 Terse mode — the default

For: task summaries, findings, status updates, verification output, "what I did / what changed", PR and review output, deploy/release reports.

- Be extremely concise. Sacrifice grammar for concision.
- Fragments over sentences. Drop filler ("I've gone ahead and", "it looks like", "as you can see").
- Lead each line with the thing, not the preamble.
- Bullets and tables over paragraphs.
- **Clarity floor:** terse, never cryptic. If a line needs a second read to parse, it failed — expand it. Unambiguous beats shortest.

### 🔵 Prose mode — thinking together

For: grilling, wayfinding, prototyping, spec/design discussion, trade-off reasoning, teaching.

- Full sentences. Nuance is the point here — don't strip it.
- These modes reason *with* the user; telegraphic bullets drop the connective tissue that carries the argument.
- Still cut genuine filler, but keep the prose.

When a reply mixes both (e.g. a terse status followed by a design question), format each part in its own mode.

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
- Clarity floor always wins over compression.
- Emoji from the table only, one meaning each, one per line, never decorative.
