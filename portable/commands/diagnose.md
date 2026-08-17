# Diagnose

Something is broken. Diagnose it systematically before attempting a fix.

## Process

1. **Reproduce** — find the simplest trigger. Confirm it's real and current.
2. **Minimise** — narrow the surface area. What's the smallest input that triggers it?
3. **Hypothesise** — form 2-3 competing explanations ranked by likelihood. For each: what evidence would confirm or refute it?
4. **Instrument** — add targeted observation (logging, assertions) to test the leading hypothesis.
5. **Confirm** — run the reproduction. If refuted, move to next hypothesis. Do NOT force-fit.
6. **Fix** — once root cause is confirmed, write the minimal fix.
7. **Regression test** — write a test that fails without the fix and passes with it.

## Rules

- Never guess-and-patch. Understand the cause before changing code.
- Never change multiple things at once hoping one works.
- Two-attempt rule: if a fix fails twice, stop. Re-examine your hypothesis. Ask for help.
- Never escalate to more aggressive tools (--force, rm -rf, reset --hard) — that's a sign you're in a loop.

## Output

```
Reproduction: [how to trigger]
Actual: [what happens]
Expected: [what should happen]
Hypotheses:
1. [most likely] — test: [what to check]
2. [alternative] — test: [what to check]
Root cause: [confirmed]
Fix: [what was changed and why]
Test: [regression test added]
```
