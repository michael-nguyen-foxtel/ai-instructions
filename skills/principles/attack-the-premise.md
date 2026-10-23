# Attack the Premise

**Fires when:** two or more fixes that share one premise have failed the same gate.

When that happens, suspect the premise, not the fixes.

**Why:** each failed fix is evidence against the belief it assumed. A third fix on the
same premise spends effort where the evidence already says the cause is not.

**Pattern:**

- **Write the premise down.** The one sentence every failed fix assumed.
- **Test the premise before the next fix.** Find an observation that would come out
  differently if the premise were false, and make it. Look at how the failures are
  *distributed*, not only at how large they are. Make the check rerunnable
  (see [build-the-lever](build-the-lever.md)).
- **Follow the evidence.** If it contradicts the premise, the cause is elsewhere — look
  for what the failures share that the premise didn't predict. If it confirms the premise,
  ask the next "why" (see [fix-root-causes](fix-root-causes.md)); the earlier fixes may
  have treated a consequence.
- **Remove the condition instead of compensating for it.** If one part always lands on the
  losing side, change what puts it there. A mechanism that cleans up after it leaves the
  cause in place and adds work on every run.

**Stop:** do not start the next fix before the premise is written down and tested.
