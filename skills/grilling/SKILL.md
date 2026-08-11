---
name: grilling
description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
---

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled — the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask the whole frontier in one round: number each question and give your recommended answer. Then wait for the user's answers before the next round.

Each question should be formatted like so:

```
❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>
```

Each round the user answers reshapes the tree — settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a _later_ round, not this one.

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it — don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report — ask the rest of the frontier now. The _decisions_ are the user's — put each to them and wait.

## Fidelity Escalation

When a question emerges that cannot be confidently resolved through discussion alone — typically "how should it look?", "how should it behave?", or "does this state model feel right?" — pause the grill and suggest prototyping:

"This feels like it needs higher fidelity. Want me to prototype this so we can react to something concrete?"

If accepted, run `/prototype`, capture the validated decision, then resume the grill where we left off. The prototype answer becomes a locked branch in the design tree.

## Adversarial QA Pass

When the frontier is empty and before confirming shared understanding, run one final pass:

Think like an adversarial QA engineer. For each acceptance criterion and decision, ask:
- What input would break this?
- What state would make this behave unexpectedly?
- What happens under concurrent access, empty data, network failure, or malformed input?
- What could a user do that we haven't accounted for?

Present any newly discovered edge cases as additional questions. If they reveal gaps, add them as a final round.

## Done

The session is done when the frontier is empty and the adversarial pass surfaces nothing new. Do not act on it until the user confirms you have reached a shared understanding.
