# Writing for Agents

Reference for writing any document an agent consumes — a skill, a steering doc, or a doc reached by a pointer. Use when creating or editing skills, or modifying steering documents.

## Context Pointers

A **context pointer** is a reference held in the agent's context that names some out-of-context material and encodes the condition for reaching it. A skill's description is one; a line in a steering doc naming a skill is the same object.

A pointer does two jobs — state what the material is, and list the **branches** that should trigger reaching it. Every word of an always-loaded pointer costs on every turn:

- **Front-load the leading word** — the pointer is where it does its triggering work.
- **One trigger per branch.** Collapse synonyms; keep only genuinely distinct branches.
- **Cut identity the body already carries.**

## The Two Loads

Every document and pointer spends one of two budgets:

- **Context load** — the cost of always-loaded material on the agent's window. Spends tokens and attention whether or not it fires.
- **Cognitive load** — the cost on the human: which documents exist and when to reach for each. Not a cost to minimise — it is the price of human agency.

## Information Hierarchy

A document is built from **steps** (ordered actions) and **reference** (definitions, rules, facts consulted on demand). The core decision is where each piece sits:

1. **In-file step** — what the agent does, in order.
2. **In-file reference** — consulted on demand.
3. **Disclosed reference** — pushed into a separate file, loaded only when the pointer fires.

Push too little down and the top bloats; push too much and you hide needed material.

**Progressive disclosure** — the move down the ladder — protects the hierarchy. Branching is the disclosure test: inline what every branch needs, push behind a pointer what only some branches reach.

**Co-location** — keep a concept's definition, rules, and caveats under one heading rather than scattered. The document should read like documentation written for the agent.

**Sprawl** — a document simply too long. Cure: disclose reference behind pointers, split by branch or sequence.

## Steps and Completion Criteria

Every step ends on a **completion criterion** — the condition that tells the agent the work is done:

- **Clarity** — can the agent tell done from not-done? Vague bounds invite **premature completion**: ending the step before it's genuinely done. The visible steps still ahead supply pull toward ending early. Defend: **sharpen the bound first**; only if irreducibly fuzzy, hide later steps behind a context boundary.
- **Demand** — how much it requires. "Every modified model accounted for" forces thorough work where "produce a change list" does not.

The strongest criteria are both checkable and exhaustive.

## When to Split

Split one document into two only when the cut earns it:

- **By sequence** — split where post-completion steps tempt the agent to rush the current step. Keeping them out of view drives more legwork.
- **By invocation** — when a skill has distinct modes (e.g., "chart" vs "work through").

## Leading Words

A **leading word** is a compact concept from the model's pretraining that the agent thinks with while running the document: _tracer bullets_, _fog of war_, _frontier_, _vertical slice_, _deep module_.

It anchors twice:
- In the body: the agent reaches for the same behaviour every time the word appears.
- In a pointer: when the same word lives in prompts, docs, and codebase, the agent links that shared language to the material and reaches it more reliably.

Hunt for opportunities to refactor with leading words. A triad spelled out at three sites is a passage begging to collapse into a single token:
- "fast, deterministic, low-overhead" → _tight_
- "a loop you believe in" → _red_ (a binary observable state)

## Negation

Steering by prohibition drags the forbidden behaviour into context and makes it _more_ available, not less. "Don't think of an elephant" makes the elephant all there is.

Prompt the **positive** — state the target behaviour so the banned one is never spoken. A prohibition earns its place only as a hard guardrail you cannot phrase positively.

## Pruning

- **Single source of truth**: one authoritative place per meaning. Duplication costs maintenance and inflates prominence past real rank.
- **The environment is a source of truth**: `package.json` scripts, config files, directory layout, `--help` output. A document restating them is a **cache** — a copy of a lookup, earning its load only when the lookup is expensive. Cache what the agent cannot find by looking: the unwritten convention, the reason behind a choice, the edge case no config confesses.
- **Relevance**: does it still bear on what the document does? Shorter documents are easier to keep relevant.
- **No-ops**: an instruction the model already obeys by default pays load to say nothing. The test: does it change behaviour versus the default? When a sentence fails, delete the whole sentence.
