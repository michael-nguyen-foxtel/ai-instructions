#!/bin/bash
# setup.sh
# Install AI skills into your Kiro CLI configuration.
#
# Usage:
#   ./setup.sh              Interactive — pick which skills to install
#   ./setup.sh --all        Install everything (universal + team-specific)
#   ./setup.sh --universal  Install all universal skills without prompting

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_SOURCE="$SCRIPT_DIR/skills"
SKILLS_TARGET="$HOME/.kiro/skills"
STEERING_SOURCE="$SCRIPT_DIR/steering"
STEERING_TARGET="$HOME/.kiro/steering"

# Skill categories
declare -A SKILL_CATEGORIES
SKILL_CATEGORIES=(
  # The Main Flow
  [grill-with-docs]="main-flow"
  [grilling]="main-flow"
  [to-spec]="main-flow"
  [to-tickets]="main-flow"
  [implement-from-spec]="main-flow"
  [code-review]="main-flow"
  [pull-requests]="main-flow"
  [commit-messages]="main-flow"
  # Shaping
  [wayfinder]="shaping"
  [prototype]="shaping"
  [research]="shaping"
  [grill-me]="shaping"
  # Upkeep
  [improve-codebase-architecture]="upkeep"
  [diagnosing-bugs]="upkeep"
  [resolving-merge-conflicts]="upkeep"
  [security-audit]="upkeep"
  [dependency-check]="upkeep"
  # Reference
  [domain-modeling]="reference"
  [codebase-design]="reference"
  [tdd]="reference"
  [build-verify]="reference"
  [writing-for-agents]="reference"
  # Productivity
  [handoff]="productivity"
  [teach]="productivity"
  [wait-what]="productivity"
  [version-bump]="productivity"
  # Team-specific
  [deploy-coupler]="team"
  [deploy-fiso]="team"
  [environment-check]="team"
  [release-email]="team"
  [release-notes]="team"
  [release-notes-nontechnical]="team"
)

declare -A SKILL_DESCRIPTIONS
SKILL_DESCRIPTIONS=(
  [grill-with-docs]="Rounds-based interview + domain docs (ADRs, glossary)"
  [grilling]="The interview loop (design tree + frontier)"
  [to-spec]="Synthesise a conversation into a spec file"
  [to-tickets]="Break a spec into vertical-slice Jira tickets"
  [implement-from-spec]="Implement a spec: plan → build → test → review"
  [code-review]="Review a diff against conventions and spec"
  [pull-requests]="Create PRs with proper format"
  [commit-messages]="Conventional commit format"
  [wayfinder]="Chart large efforts as a decision map"
  [prototype]="Throwaway code to answer design questions"
  [research]="Background agent for primary-source research"
  [grill-me]="Stress-test an idea (no docs output)"
  [improve-codebase-architecture]="Find modules worth refactoring"
  [diagnosing-bugs]="Systematic diagnosis, never guess-and-patch"
  [resolving-merge-conflicts]="Hunk-by-hunk conflict resolution"
  [security-audit]="Check code and deps for vulnerabilities"
  [dependency-check]="Evaluate whether to add a package"
  [domain-modeling]="Maintain CONTEXT.md glossary + ADRs"
  [codebase-design]="Deep modules vocabulary"
  [tdd]="Red-green-refactor at seam boundaries"
  [build-verify]="Post-change lint + test loop"
  [writing-for-agents]="Reference for writing skills and agent docs"
  [handoff]="Compress session state for another agent"
  [teach]="Learn a topic across multiple sessions"
  [wait-what]="Re-pitch last message in plain English"
  [version-bump]="Version bump + release PR"
  [deploy-coupler]="Deploy coupler to Elastic Beanstalk"
  [deploy-fiso]="Deploy widget packages to S3 + FISO"
  [environment-check]="Pre-validate toolchain before operations"
  [release-email]="Generate release notification email"
  [release-notes]="Technical release notes from PRs"
  [release-notes-nontechnical]="User-facing release notes"
)

CATEGORY_NAMES=(
  [main-flow]="The Main Flow (grill → spec → tickets → implement → review)"
  [shaping]="Shaping (exploration and planning)"
  [upkeep]="Upkeep (maintenance and quality)"
  [reference]="Reference (invoked by other skills)"
  [productivity]="Productivity (human-facing workflows)"
  [team]="Team-Specific (deploys, releases — may need editing)"
)

CATEGORY_ORDER=(main-flow shaping upkeep reference productivity team)

# --- Functions ---

install_skill() {
  local skill_name="$1"
  local skill_dir="$SKILLS_SOURCE/$skill_name"
  if [ -d "$skill_dir" ]; then
    mkdir -p "$SKILLS_TARGET/$skill_name"
    cp -r "$skill_dir"/* "$SKILLS_TARGET/$skill_name/"
    return 0
  fi
  return 1
}

install_category() {
  local category="$1"
  local count=0
  for skill in "${!SKILL_CATEGORIES[@]}"; do
    if [[ "${SKILL_CATEGORIES[$skill]}" == "$category" ]]; then
      install_skill "$skill" && count=$((count + 1))
    fi
  done
  echo "  ✓ Installed $count skills"
}

get_skills_in_category() {
  local category="$1"
  local skills=()
  for skill in "${!SKILL_CATEGORIES[@]}"; do
    if [[ "${SKILL_CATEGORIES[$skill]}" == "$category" ]]; then
      skills+=("$skill")
    fi
  done
  # Sort them
  IFS=$'\n' sorted=($(sort <<<"${skills[*]}")); unset IFS
  echo "${sorted[@]}"
}

# --- Main ---

mode="${1:-interactive}"

if [[ "$mode" == "--all" ]]; then
  echo "Installing ALL skills to: $SKILLS_TARGET"
  echo ""
  mkdir -p "$SKILLS_TARGET"
  for category in "${CATEGORY_ORDER[@]}"; do
    echo "${CATEGORY_NAMES[$category]}"
    install_category "$category"
  done
  echo ""
  echo "Installing steering docs to: $STEERING_TARGET"
  mkdir -p "$STEERING_TARGET"
  cp "$STEERING_SOURCE"/*.md "$STEERING_TARGET/"
  echo "  ✓ Steering docs installed"

elif [[ "$mode" == "--universal" ]]; then
  echo "Installing universal skills to: $SKILLS_TARGET"
  echo ""
  mkdir -p "$SKILLS_TARGET"
  for category in "${CATEGORY_ORDER[@]}"; do
    [[ "$category" == "team" ]] && continue
    echo "${CATEGORY_NAMES[$category]}"
    install_category "$category"
  done

else
  # Interactive mode
  echo "┌─────────────────────────────────────────┐"
  echo "│  AI Skills Installer for Kiro CLI        │"
  echo "└─────────────────────────────────────────┘"
  echo ""
  echo "Target: $SKILLS_TARGET"
  echo ""
  echo "Choose what to install. For each category you can:"
  echo "  [a] Install all skills in this category"
  echo "  [n] Skip this category"
  echo "  [p] Pick individual skills"
  echo ""

  mkdir -p "$SKILLS_TARGET"
  total_installed=0

  for category in "${CATEGORY_ORDER[@]}"; do
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "${CATEGORY_NAMES[$category]}"
    echo ""

    # Show skills in this category
    skills_in_cat=($(get_skills_in_category "$category"))
    for skill in "${skills_in_cat[@]}"; do
      desc="${SKILL_DESCRIPTIONS[$skill]:-}"
      printf "  %-30s %s\n" "$skill" "$desc"
    done
    echo ""

    read -p "  Install? [a]ll / [n]one / [p]ick: " choice
    echo ""

    case "$choice" in
      a|A|"")
        for skill in "${skills_in_cat[@]}"; do
          install_skill "$skill" && total_installed=$((total_installed + 1))
        done
        echo "  ✓ Installed ${#skills_in_cat[@]} skills"
        ;;
      p|P)
        for skill in "${skills_in_cat[@]}"; do
          desc="${SKILL_DESCRIPTIONS[$skill]:-}"
          read -p "  Install $skill? ($desc) [Y/n]: " pick
          if [[ "$pick" != "n" && "$pick" != "N" ]]; then
            install_skill "$skill" && total_installed=$((total_installed + 1))
          fi
        done
        ;;
      *)
        echo "  Skipped."
        ;;
    esac
    echo ""
  done

  # Steering docs
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Steering docs (always-on context: task routing, token efficiency, testing conventions)"
  echo ""
  read -p "  Install steering docs? [y/N]: " steer
  if [[ "$steer" == "y" || "$steer" == "Y" ]]; then
    mkdir -p "$STEERING_TARGET"
    cp "$STEERING_SOURCE"/*.md "$STEERING_TARGET/"
    echo "  ✓ Steering docs installed"
  else
    echo "  Skipped."
  fi

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "✓ Installed $total_installed skills"
fi

echo ""
echo "Done. Skills are live immediately in Kiro CLI."
echo ""
echo "Next steps:"
echo "  • Review ~/.kiro/skills/ and customise to your team"
echo "  • Edit to-tickets if your Jira project key isn't WEB"
echo "  • Create steering docs at ~/.kiro/steering/ for your products"
