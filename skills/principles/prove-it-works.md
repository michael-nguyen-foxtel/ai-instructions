# Prove It Works

**Fires when:** a task is complete, before declaring it done.

Verify every output by checking the real thing directly. Don't infer from proxies,
self-reports, or "it compiles."

**Why:** unverified work has unknown correctness. Indirect verification (file timestamps,
output freshness, a self-report, a cached screenshot) feels cheaper than direct
observation. Acting on a wrong inference costs far more than checking the source.

- Check process liveness directly, not through derived state.
- Read the actual value, not a cached or derived representation.
- When verification fails, suspect the observation method before suspecting the system.

**Script the check when you can.** The strongest proof is a deterministic script that
re-runs the same comparison, not a one-time eyeball. Write it, run it, and keep its output
as an artifact a reviewer can rerun instead of trusting your word (this is
[build-the-lever](build-the-lever.md) applied to verification). Keep the artifact visible;
commit it only for large or complex work where the trail has to be auditable later.
