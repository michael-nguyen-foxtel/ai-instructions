---
name: grilling
description: Grill the user relentlessly about a plan or design. Use when the user wants to stress-test a plan before building, or uses any 'grill' trigger phrases.
---

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the decision tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time, waiting for feedback on each question before continuing. Asking multiple questions at once is bewildering.

If a *fact* can be found by exploring the codebase, look it up rather than asking me. The *decisions*, though, are mine — put each one to me and wait for my answer.

When a branch is resolved, mark it closed in one sentence. Periodically consolidate the shared understanding so I can correct drift.

## Adversarial QA Pass

When all branches are resolved and before confirming shared understanding, run one final pass:

Think like an adversarial QA engineer. For each acceptance criterion and decision, ask:
- What input would break this?
- What state would make this behave unexpectedly?
- What happens under concurrent access, empty data, network failure, or malformed input?
- What could a user do that we haven't accounted for?

Present any newly discovered edge cases as additional questions. If they reveal gaps, add them to the acceptance criteria before closing.

Only after this pass is complete, confirm shared understanding.

Do not enact the plan until I confirm we have reached a shared understanding.
