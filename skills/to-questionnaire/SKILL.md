---
name: to-questionnaire
description: Turn a decision you can't fully answer into a questionnaire for someone else to fill in.
disable-model-invocation: true
---

Turn something the user can't answer alone into a **questionnaire** — a Markdown document they hand to one person to fill in async, or work through together in a meeting.

**Grill the send, not the subject.** Interview the user only about the _send_ — who it goes to, and what they need back. The questions in the document then target the gap between what the recipient knows and what the user needs.

## Process

1. **Who is it going to?** Ask the recipient's role, expertise, and relationship to the user. This fixes the tone and how much context the questionnaire must carry.

2. **What do you need back?** Ask what specific decisions or facts the user can't resolve alone. Done when you have a concrete list of what the user must walk away able to do or decide.

3. **Write the questionnaire.** Draft questions aimed at the gap, most-important-first. Write to `to-questionnaire-<slug>.md` in the current directory.

## Template

```markdown
# <Questionnaire title>

**Purpose:** why this questionnaire exists and the decision riding on it.

**From:** <user> — **To:** <recipient> — **How your answers will be used:** <where they go>

## Context

One paragraph orienting the recipient. Enough to answer well, not a page.

## How to answer

Deadline and rough effort. Partial answers and "I don't know" are useful — flag anything you're unsure of rather than skipping it.

## <Theme heading>

### <Question>

_Why this matters: <one line, only if the question could be misread>_

>

## Anything else?

Anything we didn't ask that we should know?
```

## Rules

- One idea per question — never compound
- Most-important-first within each theme
- Group under `##` headings by theme once there are more than a handful
- Include a closing catch-all ("Anything else?")
