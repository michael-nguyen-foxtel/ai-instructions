# AI Coding Conventions Template

## Overview

A single source of truth for coding conventions (commit messages, PR titles/descriptions) that installs into both **Kiro** (`.kiro/steering/`) and **VS Code Copilot** (`.github/instructions/`) instruction paths.

## Template Structure

```
project-templates/conventions/
├── docs/conventions/
│   ├── commit-messages.instructions.md   ← source of truth
│   └── pull-requests.instructions.md     ← source of truth
├── install-conventions.sh                ← installs into a target project
└── README.md
```

## Usage

### Install conventions into a project

```bash
./install-conventions.sh /path/to/your-project
```

This copies the convention files into:
- `/path/to/your-project/.kiro/steering/*.md` (Kiro steering files)
- `/path/to/your-project/.github/instructions/*.instructions.md` (Copilot instruction files)

Commit those files with the project. No sync scripts or hooks needed in the project itself.

### Update conventions

1. Edit files in `docs/conventions/` (this template)
2. Re-run `./install-conventions.sh` for each project you want to update

### What gets installed in the project

```
your-project/
├── .kiro/steering/
│   ├── commit-messages.md
│   └── pull-requests.md
└── .github/instructions/
    ├── commit-messages.instructions.md
    └── pull-requests.instructions.md
```

## How Each Tool Reads Instructions

### Kiro

Reads `.kiro/steering/*.md` — always-on context for every interaction.

### VS Code Copilot

Reads `.github/instructions/*.instructions.md` — supports YAML frontmatter with:
- `name`: display name in the UI
- `description`: shown on hover
- `applyTo`: glob pattern for conditional activation (empty = manual or always-on)

Additionally, VS Code has dedicated settings for commit and PR generation:
- `github.copilot.chat.commitMessageGeneration.instructions`
- `github.copilot.chat.pullRequestDescriptionGeneration.instructions`

These can reference the instruction files via the `file` property in `.vscode/settings.json`.

## Conventions Summary

### Commit Messages

```
type(scope): TICKET | description
```

- **type** (required): `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `perf`, `test`, `ci`, `build`
- **scope** (optional): freeform in parentheses
- **TICKET**: Jira key (e.g., `WEB-1234`) or pseudo-ticket (`WEB-CHORE`, `WEB-BUGFIX`, `WEB-FEATURE`, `WEB-REFACTOR`, `WEB-DOCS`, `WEB-TEST`)
- **description**: lowercase, imperative mood, no period

### PR Title

Same format as commit messages.

### PR Description

Sections: Summary, Jira reference(s), Related PR(s), Testing, Screenshots (optional).

### Agent Behaviour

- AI pauses for confirmation before finalising PR title, description, and scope
- AI asks for related PRs before submitting
- AI does not force-push or rebase during open PRs
- AI does not merge — left to author via GitHub web app

## Maintenance

- Conventions change? Edit `docs/conventions/*.instructions.md` and re-run the install script
- New convention file? Add it to `docs/conventions/`, the script picks up all `*.instructions.md` files
- New project? Run `./install-conventions.sh /path/to/project`
