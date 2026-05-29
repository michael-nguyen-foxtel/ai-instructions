# AI Coding Conventions Template

## Overview

A single source of truth for coding conventions (commit messages, PR titles/descriptions, branch naming, version bumps) that installs into both **Kiro** (`.kiro/skills/`) and **GitHub Copilot** (`.github/skills/`) as on-demand skills.

Skills are loaded on-demand — the agent sees the metadata at startup but only pulls in the full content when the task is relevant (e.g., creating a commit, opening a PR).

## Template Structure

```
project-templates/conventions/
├── docs/skills/
│   ├── commit-messages/SKILL.md
│   ├── pull-requests/SKILL.md
│   ├── branch-naming/SKILL.md
│   └── version-bump/SKILL.md
├── install-conventions.sh
└── README.md
```

## Usage

### Install conventions into a project

```bash
./install-conventions.sh /path/to/your-project
```

This copies the convention files into:
- `/path/to/your-project/.kiro/skills/<name>/SKILL.md` (Kiro skills)
- `/path/to/your-project/.github/skills/<name>/SKILL.md` (Copilot skills)

Commit those files with the project.

### Update conventions

1. Edit files in `docs/skills/` (this template)
2. Re-run `./install-conventions.sh` for each project you want to update

### What gets installed in the project

```
your-project/
├── .kiro/skills/
│   ├── commit-messages/SKILL.md
│   ├── pull-requests/SKILL.md
│   ├── branch-naming/SKILL.md
│   └── version-bump/SKILL.md
└── .github/skills/
    ├── commit-messages/SKILL.md
    ├── pull-requests/SKILL.md
    ├── branch-naming/SKILL.md
    └── version-bump/SKILL.md
```

## How Each Tool Reads Skills

### Kiro

Reads `.kiro/skills/*/SKILL.md` — metadata loaded at startup, full content pulled in on demand when the agent determines the skill is relevant.

### GitHub Copilot

Reads `.github/skills/*/SKILL.md` — discoverable by agents and invokable via `/command` in VS Code Chat. Same SKILL.md format with `name` and `description` frontmatter.

## Maintenance

- Conventions change? Edit `docs/skills/*/SKILL.md` and re-run the install script
- New convention? Add a new skill directory under `docs/skills/`
- New project? Run `./install-conventions.sh /path/to/project`
