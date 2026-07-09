---
name: writing-great-skills
description: Reference for writing and editing skills well — the vocabulary and principles that make a skill predictable.
disable-model-invocation: true
---

A skill exists to wrangle determinism out of a stochastic system. **Predictability** — the agent taking the same *process* every run, not producing the same output — is the root virtue.

## Invocation

Two choices:

- A **model-invoked** skill has a description the agent can fire autonomously and other skills can reach. Costs **context load** — the description sits in the window every turn.
- A **user-invoked** skill (`disable-model-invocation: true`) only fires when you type it. Zero context load, but costs **cognitive load** — you must remember it exists.

Pick model-invocation only when the agent must reach the skill on its own, or another skill must compose it.

## Information hierarchy

1. **In-skill step** — an ordered action in SKILL.md. Each step ends on a **completion criterion** that's checkable and exhaustive.
2. **In-skill reference** — definitions, rules, or facts consulted on demand.
3. **External reference** — pushed into a separate file via a **context pointer** (link), loaded only when needed.

**Progressive disclosure**: push material down the ladder so the top stays legible. Inline what every run needs; disclose behind a pointer what only some branches reach.

## Pruning

- **Single source of truth** — keep each meaning in one place.
- **Relevance** — does this line still bear on what the skill does?
- **No-op test** — run on each sentence: does it change behaviour versus the model's default? If not, delete it. The model already knows how to ask questions, format markdown, be thorough — don't repeat these.
- **Negation** — steering by prohibition backfires ("don't think of an elephant"). State the target behaviour positively. Keep prohibitions only as hard guardrails you can't phrase positively.

## Leading words

A **leading word** is a compact concept from the model's pretraining that anchors behaviour in the fewest tokens. Examples:

- "branch" — the agent thinks in decision trees
- "seam" — testing boundary from Feathers' *Working Effectively with Legacy Code*
- "tracer bullet" — from *The Pragmatic Programmer*, a thin vertical slice through all layers
- "relentlessly" — sets the intensity dial without spelling out "don't give up, keep pushing, ask follow-ups"

Hunt for opportunities to collapse verbose descriptions into single leading words. You win twice: fewer tokens, and a sharper hook for the agent.

## Composability

Skills can call other skills. The taxonomy:

- **User-invoked** skills orchestrate (call model-invoked skills, set up context)
- **Model-invoked** skills hold reusable discipline (can be reached by any orchestrator)
- A user-invoked skill may invoke model-invoked skills, but never another user-invoked one

If multiple user-invoked skills need the same behaviour, extract it into a model-invoked skill and have them compose it.

## Failure modes

- **Premature completion** — ending a step before it's done. Fix: sharpen the completion criterion.
- **Duplication** — same meaning in more than one place. Costs maintenance and tokens.
- **Sediment** — stale layers that settle because adding feels safe and removing feels risky.
- **Sprawl** — skill too long even when every line is live. Fix: progressive disclosure.
- **No-op** — a line the model already obeys by default.
- **Negation** — "don't do X" names X and makes it more available, not less.
