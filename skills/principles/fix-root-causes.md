# Fix Root Causes

**Fires when:** debugging.

Fix the fault, not the place where it surfaced. The symptom is where a wrong state became
visible. The root cause is the first place the system did something it should not, or
failed to handle a state it should.

**Why:** a symptom fix hides the evidence and leaves the fault free to surface elsewhere.
Each one makes the system harder to reason about — the code now carries a workaround for a
bug nobody named.

**Pattern:**

- Reproduce first.
- Ask "why" at each step until the answer is a wrong decision in the code, not a
  consequence of an earlier one.
- When stuck, instrument. Read the actual error and the actual state — don't guess.
- Ask whether the state that triggered the symptom is legitimate. If the system may be in
  that state, the code that broke on it is the root cause, and handling it there is the
  fix. If the state should never exist, a guard where it broke hides the bug — find what
  produced the state. Guards, retries, swallowed errors, clamped values, and discarded
  state are the usual ways to hide a bug.
- When something fails only after a restart, suspect persisted state first: config, caches,
  lock files, serialized state.
- Check for the pattern, not just the instance. Fix every place with the same fault.
- If a workaround needs a paragraph-long comment to justify it, the code is wrong. Fix the
  code, not the comment.
