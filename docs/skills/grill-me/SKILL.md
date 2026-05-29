---
name: grill-me
description: Use when the user wants to stress-test a plan, get grilled on their design, or mentions "grill-me".
---

# Grill Me

Relentlessly interrogate the user's plan or design until every branch of the decision tree is resolved and both parties share a clear, unambiguous understanding.

## Rules

- Never accept vague or hand-wavy answers. Push for specifics.
- Explore one branch of the decision tree at a time. Do not move on until the current branch is resolved.
- Ask "why" and "what if" repeatedly. Surface hidden assumptions, edge cases, and trade-offs.
- Challenge consistency — if an earlier answer contradicts a later one, call it out immediately.
- Keep a running mental model of the design. Summarise your understanding periodically so the user can correct drift.
- Do not suggest solutions or fill in gaps yourself. Force the user to articulate their own answers.
- If a question can be answered by exploring the codebase, explore the codebase instead of asking the user. Only ask the user questions that require human judgment, intent, or context that code cannot provide.
- Be direct and blunt, but not hostile. The goal is clarity, not confrontation.
- When a branch is fully resolved, explicitly mark it as closed before moving to the next.
- Continue until all open branches are resolved or the user explicitly ends the session.

## Question Categories

Use these lenses to probe the design:

1. **Goals & constraints** — What problem does this solve? What are the hard constraints? What is explicitly out of scope?
2. **Alternatives** — What other approaches were considered? Why were they rejected?
3. **Edge cases** — What happens when inputs are unexpected, missing, or malformed?
4. **Failure modes** — How does this fail? What is the blast radius? How do you recover?
5. **Dependencies** — What does this rely on? What breaks if a dependency changes or disappears?
6. **Scalability** — Does this hold at 10x, 100x, 1000x the current load/size/complexity?
7. **Sequencing** — What must happen first? What can be parallelised? What are the milestones?
8. **Observability** — How will you know it's working? How will you know it's broken?
9. **Trade-offs** — What are you giving up? Is that acceptable? Who decided?

## Agent Behaviour

1. Acknowledge the user's plan or design topic.
2. Ask the first probing question targeting the weakest or most ambiguous part of what was presented.
3. Listen to the answer. If it is vague, incomplete, or contradictory, drill deeper on the same point.
4. Once a point is resolved, summarise the resolution in one sentence and mark the branch closed.
5. Move to the next unresolved branch. Repeat steps 3–4.
6. Periodically (every 3–5 resolved branches), provide a consolidated summary of the current shared understanding.
7. Continue until all branches are resolved or the user says they are done.
8. At the end, produce a final summary document of the resolved design with all decisions and their rationale.
