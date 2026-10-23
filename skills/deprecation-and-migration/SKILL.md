---
name: deprecation-and-migration
description: Manages deprecation and migration — treating code as a liability to be removed once it stops earning its keep, and moving consumers safely from an old implementation to a new one. Covers the strangler, adapter, and feature-flag patterns, expand/contract for any in-place rename across a rollout window, and zombie-code removal. Use when replacing an old system, sunsetting a feature, consolidating duplicate implementations, planning a new system's eventual removal, or migrating consumers across a version boundary (including the FISO widget-version coupling).
---

# Deprecation and Migration

## Overview

Code is a liability, not an asset. Every line has ongoing cost — bugs, dependency
updates, security patches, and mental overhead for anyone working nearby. Deprecation is
the discipline of removing code that no longer earns its keep; migration is moving
consumers safely from old to new. Most teams are good at building and bad at removing.
This skill addresses that gap.

## When to Use

- Replacing an old system, API, or widget with a new one
- Sunsetting a feature that's no longer needed
- Consolidating duplicate implementations (common across the widgets/web-server split)
- Removing dead code nobody owns but something depends on
- Planning a new system's lifecycle (deprecation planning starts at design time)
- Migrating consumers across a version boundary, including the FISO coupling

## Core Principles

### Code is a liability

The value is the functionality, not the code. When the same functionality needs less
code, less complexity, or a better abstraction, the old code should go.

### Hyrum's Law makes removal hard

With enough consumers, every observable behavior gets depended on — including bugs and
undocumented side effects. This is why deprecation requires active migration, not just
announcement. Consumers can't "just switch" when they depend on behaviors the
replacement doesn't replicate.

### Deprecation planning starts at design time

When building something new, ask "how would we remove this in 3 years?" Clean interfaces,
feature flags, and minimal surface area are easier to deprecate than systems that leak
implementation everywhere.

## The Deprecation Decision

Before deprecating anything:

```
1. Does this still provide unique value?        → if yes, maintain it
2. How many consumers depend on it?             → quantify the scope
3. Does a replacement exist?                    → if no, build it first
4. What's the migration cost per consumer?      → automate if trivial; weigh if manual
5. What's the cost of NOT deprecating?          → security risk, engineer time, complexity
```

## Compulsory vs Advisory

| Type | When | Mechanism |
|------|------|-----------|
| **Advisory** | Migration optional, old system stable | Warnings, docs, nudges; consumers migrate on their own timeline |
| **Compulsory** | Old system has security issues, blocks progress, or is too costly to maintain | Hard deadline + migration tooling |

**Default to advisory.** Compulsory requires providing tooling, docs, and support — you
can't just announce a deadline.

## The Migration Process

### Step 1: Build the replacement

Don't deprecate without a working alternative. It must cover the critical use cases, have
a migration guide, and be proven in production — not just "theoretically better."

### Step 2: Announce and document

A deprecation notice with status, replacement, removal date (or "advisory — no deadline"),
reason, and a concrete migration guide.

### Step 3: Migrate incrementally

One consumer at a time: identify touchpoints → update to the replacement → verify behavior
matches → remove old references → confirm no regressions.

**The churn rule:** if you own the infrastructure being deprecated, you own migrating your
consumers — or you ship a backward-compatible change that needs no migration. Don't
announce and walk away.

### Step 4: Remove the old system

Only after every consumer has migrated: verify zero usage (metrics, logs, dependency
analysis), remove the code, remove its tests/docs/config, remove the deprecation notices.
Removing code is an achievement.

## Migration Patterns

### Strangler

Run old and new in parallel, route traffic incrementally from old to new, remove the old
when it handles 0%.

```
0% new / 100% old → 10% (canary) → 50% → 100% new / old idle → remove old
```

### Adapter

An adapter translates the old interface to the new implementation. Consumers keep the old
interface while you migrate the backend.

```javascript
// Old interface, new implementation
class LegacyTaskService {
    constructor(newService) { this.newService = newService; }
    getTask(id) {
        return this.toOldFormat(this.newService.findById(String(id)));
    }
}
```

### Feature-flag migration

Switch consumers one at a time behind a flag:

```javascript
function getTaskService(userId) {
    return featureFlags.isEnabled('new-task-service', { userId })
        ? new NewTaskService()
        : new LegacyTaskService();
}
```

### Expand/contract — never rename in place across a rollout

Any in-place rename is risky during the rollout window, because old and new code run at
once and one of them references a name the other doesn't have. Migrate additively so both
are valid at every step.

```
EXPAND ──────────────→ MIGRATE ──────────────→ CONTRACT
add the new form       dual-write / dual-read  once nothing reads the
beside the old,        old + new, migrate       old form, remove it in a
nothing reads it yet   consumers in batches     separate, later change
```

This is the same expand/contract the `to-tickets` skill sequences for wide refactors —
expand first, migrate call sites in batches (each its own ticket, blocked by the expand),
contract last. Treat each phase as a thin vertical slice (`implement-from-spec`).

**Rules:**

- **Additive first, destructive last and alone.** Adds are safe in any change; drops and
  renames get their own change *after* nothing references the old shape.
- **Every migration has a tested reverse path.** A change you can't reverse is a deploy you
  can't roll back.
- **Batch the bulk work off the hot path.** Don't do it all in one locking pass.

### Database schema migrations

Rare in the widget/web-server front-ends, but when a change does reach a schema, the data
is the one thing a deploy-revert can't roll back. Apply expand/contract above: add a new
nullable column, dual-write, backfill in throttled batches, switch reads, then drop the old
column in a separate later deploy. Never couple a destructive schema change to the code
change that needs it.

## The FISO Version-Coupling Case

Deprecating or replacing a widget in this stack is a **coupled migration**, not a single
deploy — the web-server pins the served widget version. The pattern is strangler + the
coupling dance from the product steering:

- Staging tracks `main` (FISO `staging` = `'main'`), so a new widget is live on staging
  the moment it merges — that's your canary surface.
- Production pins the version in source (`FISO_VERSIONS.production` in the web-server's
  `constants.js`), so the old widget keeps serving in prod until the web-server is repinned
  and redeployed. That pin **is** your strangler switch: old stays at 100% in prod until you
  move it.
- To remove an old widget path: ship the replacement, let staging bake, repin production,
  redeploy, confirm zero usage, *then* remove the old path. The repin is the cutover; the
  removal is a separate later change — expand/contract applied to the deploy coupling.

See the product steering's Releasing section for the exact repin/redeploy sequence; this
skill is the *why*, that's the *how*.

## Zombie Code

Code nobody owns but something depends on — no recent commits, no maintainer, accruing
vulnerabilities. Signs: no commits in 6+ months with active consumers, no owner, failing
tests nobody fixes, vulnerable deps nobody updates. **Response:** assign an owner and
maintain it, or deprecate it with a concrete migration plan. It can't stay in limbo.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "It still works, why remove it?" | Unmaintained working code accrues security debt and complexity silently |
| "Someone might need it later" | If needed later, rebuild it. Keeping it "just in case" costs more |
| "The migration is too expensive" | Compare to 2–3 years of maintenance; migration is usually cheaper long-term |
| "We'll deprecate after the new system ships" | By then you'll have new priorities. Plan removal at design time |
| "Consumers will migrate on their own" | They won't. Provide tooling, or do it yourself (the churn rule) |
| "We can maintain both indefinitely" | Two systems doing one job is double the maintenance, testing, and onboarding |
| "Just rename it, it's one line" | During rollout, old and new run together — one breaks. Expand/contract, never rename in place |

## Red Flags

- Deprecated system with no replacement available
- A deprecation announcement with no migration tooling or docs
- "Soft" deprecation advisory for years with no progress
- Zombie code with no owner and active consumers
- New features added to a deprecated system (invest in the replacement)
- Deprecation without measuring current usage
- Removing code without verifying zero consumers
- A widget path removed before production was repinned off it
- An in-place rename rather than expand/contract across a rollout

## Verification

- [ ] Replacement is production-proven and covers the critical use cases
- [ ] Migration guide exists with concrete steps
- [ ] All active consumers migrated (verified by metrics/logs)
- [ ] Old code, tests, docs, config fully removed
- [ ] No references to the deprecated system remain
- [ ] For a widget: production was repinned and redeployed before the old path was removed
- [ ] Any in-place rename went through expand/contract, not a single edit

## See Also

- `to-tickets` — sequences expand/contract for wide refactors as blocked ticket batches
- `implement-from-spec` — each migration phase as a thin vertical slice
- product steering (Releasing) — the exact FISO repin/redeploy sequence
- `diagnosing-bugs` — when a migration surfaces a behavior difference

## Adapted from

[addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) (MIT), with the
schema-migration depth trimmed and a FISO version-coupling section added for this stack.
