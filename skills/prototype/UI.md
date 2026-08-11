# UI Prototype

Generate several radically different UI variations on a single route, switchable via URL search param.

## Shape

- All variations live on one route (e.g. `/prototype?variant=a`)
- A floating bottom bar lets the user switch between variants without editing URLs
- Each variant is a genuinely *different* approach, not a minor tweak — explore the design space
- Use the project's existing component library (quicksilver) where it speeds things up, but don't let it constrain exploration

## Approach

1. Create a prototype route following the project's routing convention
2. Build 2-4 visually distinct variations of the same UI
3. Wire up a simple variant switcher (bottom-fixed bar with buttons)
4. Each variant should be self-contained — don't share state between them unless that's what you're testing

## What "radically different" means

- Different layout structures (sidebar vs top-nav, cards vs list, wizard vs single-page)
- Different information hierarchy (what's prominent, what's hidden)
- Different interaction models (inline editing vs modal, progressive disclosure vs all-at-once)

Don't just change colours or spacing — those are styling decisions, not design decisions.

## Iteration

After the user reacts to the variants, combine the best aspects into a refined version. Repeat until the user says "this is it." Each iteration is a design decision being locked — note what was chosen and why.

Don't ask "which one?" — ask what they like and dislike about each, then synthesise. The goal is convergence through reaction, not selection from a menu.
