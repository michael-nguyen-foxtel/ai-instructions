---
name: diagnosing-bugs
description: Disciplined diagnosis loop for hard bugs and performance regressions. Use when a bug is reported, a test is failing unexpectedly, or behaviour doesn't match expectations.
---

# Diagnosing Bugs

Systematic diagnosis loop: reproduce → minimise → hypothesise → instrument → fix → regression-test. Never guess-and-patch.

## When to Use

- A bug is reported and the cause is not immediately obvious
- A test is failing and the reason is unclear
- Behaviour doesn't match what the code appears to do
- Performance has regressed without an obvious change

## The Loop

### 1. Reproduce

Get a reliable reproduction before doing anything else.

- Find or write the simplest trigger (test, curl, UI action)
- Confirm the bug is real and current (not already fixed on main)
- Record the actual vs. expected behaviour
- If you cannot reproduce, state that clearly — do NOT proceed to fix

### 2. Minimise

Narrow the surface area.

- Identify the smallest input that triggers the bug
- Remove unrelated code paths from consideration
- Use git bisect (mentally or actually) to find when it broke
- Isolate: is it data? timing? environment? code logic?

### 3. Hypothesise

Form 2-3 competing hypotheses ranked by likelihood.

For each hypothesis state:
- What would be true if this hypothesis is correct
- What evidence would confirm or refute it
- Where in the code to look

Do NOT jump to a fix. Pick the most likely hypothesis and test it first.

### 4. Instrument

Add targeted observation to confirm or refute the leading hypothesis.

- Add logging, breakpoints, or assertions at the suspected location
- Run the reproduction again
- If the hypothesis is refuted, move to the next one — do NOT force-fit
- If no hypothesis survives, step back and re-examine assumptions

### 5. Fix

Once the root cause is confirmed:

- Write the minimal fix that addresses the root cause
- Do NOT fix symptoms or add defensive code around the bug
- If the fix touches shared code, consider blast radius

### 6. Regression Test

- Write a test that fails without the fix and passes with it
- The test should encode the exact scenario from step 1
- Run the full relevant test suite to confirm no regressions

## Anti-Patterns (never do these)

- **Guess-and-patch**: making changes without understanding the cause
- **Shotgun debugging**: changing multiple things at once hoping one works
- **Fix the symptom**: adding a null check instead of understanding why it's null
- **Blame the framework**: assuming a library bug before checking your own code
- **Skip reproduction**: jumping to a fix based on the bug report alone

## Output Format

When diagnosing, structure your thinking as:

```
**Reproduction**: [how to trigger]
**Actual**: [what happens]
**Expected**: [what should happen]
**Hypotheses**:
1. [most likely] — evidence needed: [what to check]
2. [alternative] — evidence needed: [what to check]
**Investigation**: [what was found]
**Root Cause**: [confirmed cause]
**Fix**: [what was changed and why]
**Regression Test**: [test added]
```
