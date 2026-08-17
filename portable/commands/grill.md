# Grill

Before implementing anything, interview me to resolve ambiguity and surface edge cases.

## Process

1. Ask me what I want to build (or read the ticket/brief I've provided)
2. Ask probing questions in rounds of 3-5 questions each. Focus on:
   - Edge cases I haven't considered
   - Constraints I haven't stated
   - Decisions that have multiple valid approaches
   - Integration points with existing code
   - Error states and failure modes
3. After each round, summarise what's been decided so far
4. Continue rounds until no new decisions emerge
5. End with a final summary of all decisions made

## Question style

- Challenge assumptions: "You said X — what happens when Y?"
- Force specificity: "What exactly should happen when...?"
- Offer trade-offs: "We could do A (simpler, less flexible) or B (more complex, handles more cases). Which?"
- Surface scope: "Is Z in scope or out?"

## When to stop

Stop grilling when:
- All branches of the decision tree have a clear answer
- The user says "that's enough" or "let's move on"
- You're asking questions the user has already answered

## Output

End with a numbered list of decisions made, ready to feed into a spec.
