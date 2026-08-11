#!/bin/bash
# setup.sh
# Install universal AI skills into your Kiro CLI configuration.
# Team-specific skills (deploys, release emails) are excluded.
#
# Usage: ./setup.sh [--all]
#   Default: installs only universal skills
#   --all:   installs everything (only use if you're on the same team)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_SOURCE="$SCRIPT_DIR/skills"
SKILLS_TARGET="$HOME/.kiro/skills"
STEERING_SOURCE="$SCRIPT_DIR/steering"
STEERING_TARGET="$HOME/.kiro/steering"

# Universal skills — useful for any engineer
UNIVERSAL_SKILLS=(
  build-verify
  code-review
  codebase-design
  commit-messages
  dependency-check
  diagnosing-bugs
  domain-modeling
  grill-me
  grill-with-docs
  grilling
  handoff
  implement-from-spec
  improve-codebase-architecture
  prototype
  pull-requests
  research
  resolving-merge-conflicts
  security-audit
  tdd
  teach
  to-spec
  to-tickets
  version-bump
  wait-what
  wayfinder
  writing-for-agents
)

# Team-specific skills — excluded by default
TEAM_SKILLS=(
  deploy-coupler
  deploy-fiso
  environment-check
  release-email
  release-notes
  release-notes-nontechnical
)

install_all=false
if [[ "$1" == "--all" ]]; then
  install_all=true
fi

echo "Installing skills to: $SKILLS_TARGET"
echo ""

mkdir -p "$SKILLS_TARGET"

installed=0
skipped=0

for skill_dir in "$SKILLS_SOURCE"/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name="$(basename "$skill_dir")"

  if [[ "$install_all" == false ]]; then
    # Check if this is a team-specific skill
    is_team=false
    for team_skill in "${TEAM_SKILLS[@]}"; do
      if [[ "$skill_name" == "$team_skill" ]]; then
        is_team=true
        break
      fi
    done

    if [[ "$is_team" == true ]]; then
      skipped=$((skipped + 1))
      continue
    fi
  fi

  # Copy skill directory
  mkdir -p "$SKILLS_TARGET/$skill_name"
  cp -r "$skill_dir"* "$SKILLS_TARGET/$skill_name/"
  installed=$((installed + 1))
done

echo "✓ Installed $installed skills"
if [[ $skipped -gt 0 ]]; then
  echo "  Skipped $skipped team-specific skills (use --all to include them)"
fi

# Steering docs — only install with --all
if [[ "$install_all" == true ]]; then
  echo ""
  echo "Installing steering docs to: $STEERING_TARGET"
  mkdir -p "$STEERING_TARGET"
  cp "$STEERING_SOURCE"/*.md "$STEERING_TARGET/"
  echo "✓ Steering docs installed"
else
  echo ""
  echo "Steering docs skipped (team-specific). Use --all if you're on the same team."
fi

echo ""
echo "Done. Skills are live immediately in Kiro CLI."
echo ""
echo "Recommended next steps:"
echo "  • Review ~/.kiro/skills/ and remove any you don't want"
echo "  • Edit skills to match your team's conventions (Jira project, cloud IDs, etc.)"
echo "  • Create your own steering docs at ~/.kiro/steering/"
