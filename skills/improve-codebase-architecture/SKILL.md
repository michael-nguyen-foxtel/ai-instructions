---
name: improve-codebase-architecture
description: Scan a codebase for deepening opportunities, present them as a visual HTML report, then grill through whichever one you pick. Run periodically (~fortnightly) per repo.
---

# Improve Codebase Architecture

Surface architectural friction and propose deepening opportunities — refactors that turn shallow modules into deep ones. Uses the `codebase-design` skill vocabulary throughout.

## Process

### 1. Explore

Read any domain steering file (`.kiro/steering/domain.md`) and the product steering file for context. Then walk the codebase organically and note friction:

- Where does understanding one concept require bouncing between many small modules?
- Where are modules shallow — interface nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they're called (no locality)?
- Where do tightly-coupled modules leak across their seams?
- Which parts are untested or hard to test through their current interface?

Apply the **deletion test**: would deleting a module concentrate complexity? If yes, it was earning its keep. If complexity vanishes, it was pass-through.

### 2. Present candidates as an HTML report

Write a self-contained HTML file to `$TMPDIR/architecture-review-<timestamp>.html`. Open it with `open <path>` (macOS). Tell the user the absolute path.

The report uses:
- **Tailwind via CDN** for layout
- **Mermaid via CDN** for dependency/call graphs
- Hand-built divs/SVG for editorial visuals (mass diagrams, before/after cross-sections)

Each candidate card contains:
- **Files** — which modules are involved
- **Problem** — why the current architecture causes friction (using glossary terms)
- **Solution** — plain English description of what would change
- **Benefits** — explained in terms of locality and leverage
- **Before/After diagram** — side-by-side showing the shallowness and the deepening
- **Recommendation strength** — `Strong` | `Worth exploring` | `Speculative`

End with a **Top recommendation** section.

After writing the file, ask: "Which of these would you like to explore?"

### 3. Grilling loop

Once the user picks a candidate, grill them through the design:
- Constraints and dependencies
- Shape of the deepened module
- What sits behind the seam
- What tests survive and what new tests are needed

As decisions crystallise:
- If naming a concept not in the domain file → add it
- If sharpening a fuzzy term → update the domain file
- If user rejects with a load-bearing reason → offer to record it so future reviews don't re-suggest it

### 4. Output

After grilling is complete, produce:
- A summary of the agreed design
- File paths affected
- Suggested implementation order
- Any domain vocabulary updates made

## Vocabulary (from codebase-design)

Use exactly: **module**, **interface**, **implementation**, **depth**, **seam**, **adapter**, **leverage**, **locality**.

Never substitute: component, service, unit (for module) · API, signature (for interface) · boundary (for seam) · layer, wrapper (for module).

## HTML Report Style

- Editorial, not dashboard. Generous whitespace.
- Colour sparingly: emerald for deep modules, red for leakage, amber for warnings.
- Diagrams ~320px tall so before/after sits side by side.
- `text-xs uppercase tracking-wider` for module labels inside diagrams.
- Static HTML — no app code beyond Tailwind and Mermaid CDN scripts.
