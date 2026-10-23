# Explain the Number

**Fires when:** before you trust, report, or act on a number you measured — a speedup, a
regression, a throughput, a latency, an eval result.

Find what limits it, and rule out that it measured something other than the work you think.

- **Ask "why not double?"** Name the resource or code path that bounds the result — a core,
  a lock, the disk, the network, or the load generator itself. Get it from a profile or
  from system counters taken during the run, then map it to source. A guess from reading
  the code is not a limiter. If you can't say why the number isn't twice as good, you don't
  know what you measured.
- **List what else the number could be measuring, and rule out each with evidence.** The
  usual suspects: errors, skipped or cached work, code that never ran, an untuned side (one
  left on defaults), noise, and a piece too small to matter end to end.
- **Keep the evidence with the number.** Record the run count, the spread, and the limiter
  in the notes or a linked artifact. For an eval result, ask the same of the trials: did
  every run do the task, does the gap hold across trials, does the scenario matter.

You skipped this when the evidence behind a number has no run count, no spread, or no named
limiter — or when the time saved is larger than the time the changed piece took.

Distinct from [prove-it-works](prove-it-works.md), which checks that an output is real.
This checks that a *number* means what you think.
