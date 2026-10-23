# Build the Lever

**Fires when:** the work isn't trivial — edits, migrations, analyses, checks.

Build the tool that does the work instead of doing it by hand. A codemod, generator, or
script does the work the same way every time and reruns for free. The tool is one artifact
a reviewer can read and rerun to check the work; hand-done changes can only be re-verified
by redoing them. A deterministic script turns "trust me" into "run this."

Default to building the lever. Skip it only when the task is trivial — a couple of obvious
edits you can see at a glance.

- Do the first unit by hand to learn the recipe, then build the tool. Prove it by
  rerunning on that unit and diffing against your hand-done version. Make the lever safe to
  rerun.
- Codemod or script for edits, generator for repetitive files, a dump-to-query for
  analysis, a rerunnable check for verification.
- **A deterministic lever beats fan-out.** If the tool can process every unit in one pass,
  run it — don't fan out subagents to hand-apply what a script can do.
- **When you do fan work out to subagents, write the lever as a skill they all read:** the
  recipe, the verification contract, and the do-not-touch fences in one artifact, kept
  outside the delegates' write scope so they can't quietly edit the contract.
- Applying this produces a file. If you cited it and there's no script, codemod, generator,
  or delegate skill in the diff, you didn't apply it.
- Build the smallest script that does or proves the job, never a framework.

Distinct from making a recurring rule a durable guardrail (that's a lint/check/metadata
flag). This is throughput and reviewability on the work in front of you.
