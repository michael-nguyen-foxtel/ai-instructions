# Conventions — Steering & Instructions

This directory holds always-on steering files (Kiro) and instructions files (GitHub Copilot) that apply to every interaction, not just specific tasks.

For task-specific conventions (commits, PRs, branching, versioning), see `docs/skills/`.

## Kiro Steering

Steering files are installed to `.kiro/steering/` in the target project. They use markdown with optional frontmatter for inclusion rules.

## GitHub Copilot Instructions

Instructions files are installed to `.github/instructions/` in the target project. They use the `.instructions.md` format with `applyTo` frontmatter for glob-based file matching.
