# Wayfinder

Plan a large effort — more than one agent session can hold — as a map of decision tickets on Jira, and resolve them one at a time until the way to the destination is clear.

A loose idea has arrived — too big for one agent session, and wrapped in fog: the way from here to the **destination** isn't visible yet. Wayfinding is about finding that way, not charging at the destination. This skill charts the way as a **shared map** on Jira, then works its **decision tickets** — questions whose resolution is a decision, not slices of a build to execute — one at a time until the route is clear.

## Plan, don't do

Wayfinder is **planning** by default: each ticket resolves a decision, and the map is done when the way is clear — nothing left to decide before someone goes and does the thing. The pull to just do the work is the signal you've reached the edge of the map and it's time to hand off to `/to-spec`.

## The Map

The map is a single Jira issue (Epic or Story) labelled `wayfinder-map` — the canonical artifact. Its decision tickets are sub-tasks or linked issues.

The map is an **index**, not a store. It lists the decisions made and points at the tickets that hold their detail; a decision lives in exactly one place — its ticket.

### Map body (Jira description)

```markdown
## Destination

<what reaching the end of this map looks like — the spec, decision, or change this effort is finding its way to>

## Notes

<domain; skills every session should consult; standing preferences>

## Decisions so far

- WEB-XXXX: <one-line gist of the answer>
- WEB-YYYY: <one-line gist of the answer>

## Not yet specified

<fog of war: in-scope questions you can't ticket yet; graduates as the frontier advances>

## Out of scope

<work ruled beyond the destination; never graduates>
```

### Decision Tickets

Each ticket is a linked issue of the map. Its description holds the question:

```markdown
## Question

<the decision or investigation this ticket resolves>
```

Each ticket is one of four types (use Jira labels):

- **wayfinder-research** (AFK): Agent investigates docs, APIs, code to surface a fact. Resolved by a `/research` subagent.
- **wayfinder-prototype** (HITL): Make a cheap artifact to react to. Links the prototype as evidence.
- **wayfinder-grilling** (HITL): Conversation. Run `/grilling` and `/domain-modeling`.
- **wayfinder-task** (AFK/HITL): Manual work that unblocks a decision (provisioning, config, etc.)

Blocking uses Jira's native "Blocks" link type. A ticket is **unblocked** when every ticket blocking it is closed. The **frontier** is the open, unblocked tickets.

## Fog of War

The map is deliberately incomplete: don't chart what you can't yet see. Beyond the live tickets lies the **fog of war** — decisions you can tell are coming but can't yet pin down. Resolving a ticket clears the fog ahead of it, graduating whatever's now specifiable into fresh tickets.

**Fog or ticket?** The test: can you state the question precisely now?
- **Ticket** when the question is sharp — even if blocked.
- **Fog** when you can't phrase it that sharply yet.

## Invocation

Two modes. **Never resolve more than one ticket per session** — except research tickets which run as subagents.

### Chart the map

User invokes with a loose idea.

1. **Name the destination.** Run `/grilling` to pin down what this map is finding its way to. The destination fixes the scope.
2. **Map the frontier.** Grill **breadth-first**: fan out across the whole space rather than deep on any one thread. If this surfaces no fog — the whole journey fits one session — you don't need a map. Stop and suggest `/grill-with-docs` instead.
3. **Create the map** on Jira as an Epic with description filled per template.
4. **Create the decision tickets** as linked issues, then wire blocking edges in a second pass.
5. **Fire research subagents.** For each research ticket, spin up a `/research` subagent to resolve it in parallel.
6. Stop — charting is one session's work.

### Work through the map

User invokes with a map (Jira key).

1. Load the **map** description.
2. Choose the ticket. If the user named one, use it. Otherwise take the first frontier ticket.
3. Resolve it — invoke the skills the ticket type demands (`/grilling`, `/research`, `/prototype`).
4. Record the resolution: comment the answer on the ticket, close it, and update the map's "Decisions so far" section.
5. Add newly-surfaced tickets; graduate fog that the answer made specifiable.

## After the Map Clears

When all tickets are closed:
- Merge onto the main flow at `/to-spec` — collapse the map's linked decisions into a buildable spec.
- Go straight to `/implement` only when the effort turned out genuinely small.
