# AI Instructions

Version-controlled snapshot of my AI agent skills and steering configuration.

## Architecture

```
~/.kiro/skills/     ← LIVE (edit here, immediate effect in Kiro CLI + IDE)
~/.kiro/steering/   ← LIVE (always-on context for all sessions)
         │
         │  rsync (periodic checkpoint)
         ▼
this repo           ← VERSION HISTORY (git log of how skills evolve)
```

**This repo is not a distribution mechanism.** It's a versioned backup of what lives at `~/.kiro/`.

## Structure

```
├── skills/          ← mirrors ~/.kiro/skills/ (all universal skills)
├── steering/        ← mirrors ~/.kiro/steering/ (always-on context)
├── copilot/         ← lightweight Copilot instruction files
├── install.sh       ← sets up .github/instructions/ in a new repo
└── README.md
```

## Workflow

### Edit skills (immediate effect)

Edit directly in `~/.kiro/skills/`. Changes are live immediately in Kiro CLI and Kiro IDE.

### Checkpoint to git

```bash
cd ~/Documents/SourceCode/ai-instructions
rsync -av --delete ~/.kiro/skills/ ./skills/
rsync -av --delete ~/.kiro/steering/ ./steering/
git add -A && git commit -m "sync: $(date +%Y-%m-%d)"
git push
```

### Set up a new repo for Copilot

```bash
./install.sh /path/to/your-project
```

This copies the 3 Copilot instruction files into `.github/instructions/`.

## Skill Types

| Type | Fires when | Context cost |
|------|-----------|--------------|
| **User-invoked** | You type it manually | Zero |
| **Model-invoked** | Agent fires autonomously or composed by other skills | Always loaded |

## Key Skills

| Skill | Type | Purpose |
|-------|------|---------|
| grilling | model | Reusable interview loop |
| grill-me | user | Thin wrapper — runs /grilling |
| grill-with-docs | user | Grilling + domain-modeling (updates CONTEXT.md) |
| domain-modeling | model | Maintains CONTEXT.md glossary + ADRs |
| tdd | model | Red-green-refactor with seam discipline |
| prototype | model | Throwaway code to answer design questions |
| research | model | Background agent, primary sources |
| build-verify | model | Post-change lint + test loop |
| diagnosing-bugs | model | Systematic diagnosis, never guess-and-patch |
| codebase-design | model | Deep modules vocabulary |
| improve-codebase-architecture | user | HTML report of deepening opportunities |
| deploy-fiso | user | FISO deployment automation |
| writing-great-skills | user | Meta-reference for writing skills well |
