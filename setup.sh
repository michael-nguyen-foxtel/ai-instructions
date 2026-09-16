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
BIN_SOURCE="$SCRIPT_DIR/bin"
BIN_TARGET="$HOME/.local/bin"

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
  [stacked-prs]="main-flow"
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
  [qa-build]="upkeep"
  [wizard]="upkeep"
  # Reference
  [domain-modeling]="reference"
  [codebase-design]="reference"
  [tdd]="reference"
  [build-verify]="reference"
  [writing-for-agents]="reference"
  [cicd-conventions]="reference"
  # Productivity
  [handoff]="productivity"
  [teach]="productivity"
  [wait-what]="productivity"
  [to-questionnaire]="productivity"
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
  [stacked-prs]="Create/manage/merge stacked PRs with Graphite"
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
  [qa-build]="Push to QA branch for staging build (git push-qa)"
  [wizard]="Generate a guided, resumable operator walkthrough for human-only steps"
  [domain-modeling]="Maintain CONTEXT.md glossary + ADRs"
  [codebase-design]="Deep modules vocabulary"
  [tdd]="Red-green-refactor at seam boundaries"
  [build-verify]="Post-change lint + test loop"
  [writing-for-agents]="Reference for writing skills and agent docs"
  [cicd-conventions]="CI/CD conventions (GitHub Actions, AWS, anti-patterns)"
  [handoff]="Compress session state for another agent"
  [teach]="Learn a topic across multiple sessions"
  [wait-what]="Re-pitch last message in plain English"
  [to-questionnaire]="Turn a decision into a questionnaire for someone else"
  [version-bump]="Version bump + release PR"
  [deploy-coupler]="Deploy coupler to Elastic Beanstalk"
  [deploy-fiso]="Deploy widget packages to S3 + FISO"
  [environment-check]="Pre-validate toolchain before operations"
  [release-email]="Generate release notification email"
  [release-notes]="Technical release notes from PRs"
  [release-notes-nontechnical]="User-facing release notes"
)

# Invocation axis (upstream mattpocock/skills convention):
#   user   = user-invoked — a human triggers it (a slash command) to orchestrate.
#   model  = model-invoked — a reusable discipline that OTHER skills pull in mid-run.
# The rule: a user-invoked skill may invoke model-invoked skills, but must NEVER
# invoke another user-invoked skill INLINE in the same context window. To hand work
# to another user-invoked skill, cross a context boundary (dispatch a subagent or a
# Herdr sibling) — see the three-gate rule in steering/task-routing.md. Narrative
# "next, run /x" pointers are not invocations and are fine.
declare -A SKILL_AXIS
SKILL_AXIS=(
  # model-invoked (reference disciplines other skills pull in)
  [grilling]="model"
  [domain-modeling]="model"
  [tdd]="model"
  [build-verify]="model"
  [codebase-design]="model"
  [writing-for-agents]="model"
  [commit-messages]="model"
  [cicd-conventions]="model"
  [wizard]="model"
  # user-invoked (human triggers to orchestrate)
  [grill-with-docs]="user"
  [grill-me]="user"
  [to-spec]="user"
  [to-tickets]="user"
  [implement-from-spec]="user"
  [code-review]="user"
  [pull-requests]="user"
  [stacked-prs]="user"
  [wayfinder]="user"
  [prototype]="user"
  [research]="user"
  [improve-codebase-architecture]="user"
  [diagnosing-bugs]="user"
  [resolving-merge-conflicts]="user"
  [security-audit]="user"
  [dependency-check]="user"
  [qa-build]="user"
  [handoff]="user"
  [teach]="user"
  [wait-what]="user"
  [to-questionnaire]="user"
  [version-bump]="user"
  [deploy-coupler]="user"
  [deploy-fiso]="user"
  [environment-check]="user"
  [release-email]="user"
  [release-notes]="user"
  [release-notes-nontechnical]="user"
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

# Deploy the helper scripts in bin/ (e.g. the herd-* Herdr tooling) to
# ~/.local/bin, ensuring each is executable. No-op if bin/ is empty/missing.
install_bin() {
  if [ ! -d "$BIN_SOURCE" ] || [ -z "$(ls -A "$BIN_SOURCE" 2>/dev/null)" ]; then
    return 0
  fi
  mkdir -p "$BIN_TARGET"
  local count=0
  for script in "$BIN_SOURCE"/*; do
    [ -f "$script" ] || continue
    case "$script" in *.md) continue;; esac  # skip docs (README.md etc.)
    cp "$script" "$BIN_TARGET/"
    chmod +x "$BIN_TARGET/$(basename "$script")"
    count=$((count + 1))
  done
  echo "  ✓ Installed $count helper script(s) to $BIN_TARGET"
}

# Install the git-guard hooks (bin/git-guard) as a GLOBAL git hooksPath so that
# protected-branch and force-push protection applies to EVERY repo on this machine
# — including every repo an agent or sub-agent operates in via a `shell` tool. This
# is deliberately a git-layer boundary, not an agent-prompt request: a model cannot
# route a `git push`/`git commit` around a hook git runs on its behalf. Idempotent.
# NOTE: changes global git config (core.hooksPath), hence the caller prompts in
# interactive mode.
install_git_guard() {
  local guard_installer="$BIN_SOURCE/git-guard/install.sh"
  if [ ! -f "$guard_installer" ]; then
    return 0
  fi
  bash "$guard_installer"
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

# Warn about any skills/<dir> (containing a SKILL.md) that is NOT in
# SKILL_CATEGORIES. Such a skill is invisible to every install mode — the
# `stacked-prs` silent-drop was exactly this. Prints a warning per orphan and
# returns 1 if any were found (callers may choose to continue).
check_uncategorised_skills() {
  local orphans=()
  local axis_orphans=()
  local dir name
  for dir in "$SKILLS_SOURCE"/*/; do
    [ -f "$dir/SKILL.md" ] || continue
    name="$(basename "$dir")"
    if [ -z "${SKILL_CATEGORIES[$name]+set}" ]; then
      orphans+=("$name")
    fi
    if [ -z "${SKILL_AXIS[$name]+set}" ]; then
      axis_orphans+=("$name")
    fi
  done
  local rc=0
  if [ "${#orphans[@]}" -gt 0 ]; then
    echo "⚠  WARNING: these skills exist on disk but are missing from SKILL_CATEGORIES" >&2
    echo "   — they will NOT be installed by any mode until added to the map:" >&2
    for name in "${orphans[@]}"; do
      echo "     - $name" >&2
    done
    echo "   Add each to SKILL_CATEGORIES (and SKILL_DESCRIPTIONS) in setup.sh." >&2
    rc=1
  fi
  if [ "${#axis_orphans[@]}" -gt 0 ]; then
    echo "⚠  WARNING: these skills are missing an invocation axis in SKILL_AXIS:" >&2
    for name in "${axis_orphans[@]}"; do
      echo "     - $name" >&2
    done
    echo "   Add each to SKILL_AXIS (\"user\" or \"model\") in setup.sh." >&2
    rc=1
  fi
  return $rc
}

# --- Main ---

mode="${1:-interactive}"

# Adversarial guard: surface any on-disk skill missing from the category map
# before installing, so a new skill can never be silently dropped again.
check_uncategorised_skills || true

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
  echo ""
  echo "Installing helper scripts to: $BIN_TARGET"
  install_bin
  echo ""
  echo "Installing git-guard (global protected-branch + force-push hooks)"
  install_git_guard

elif [[ "$mode" == "--universal" ]]; then
  echo "Installing universal skills to: $SKILLS_TARGET"
  echo ""
  mkdir -p "$SKILLS_TARGET"
  for category in "${CATEGORY_ORDER[@]}"; do
    [[ "$category" == "team" ]] && continue
    echo "${CATEGORY_NAMES[$category]}"
    install_category "$category"
  done
  echo ""
  echo "Installing helper scripts to: $BIN_TARGET"
  install_bin
  echo ""
  echo "Installing git-guard (global protected-branch + force-push hooks)"
  install_git_guard

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

  # Helper scripts (bin/)
  if [ -d "$BIN_SOURCE" ] && [ -n "$(ls -A "$BIN_SOURCE" 2>/dev/null)" ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Helper scripts (Herdr session tooling: herd-launch, herd-restore, herd-pin, …)"
    echo ""
    read -p "  Install helper scripts to $BIN_TARGET? [y/N]: " binchoice
    if [[ "$binchoice" == "y" || "$binchoice" == "Y" ]]; then
      install_bin
    else
      echo "  Skipped."
    fi
  fi

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "git-guard (global git hooks: block direct pushes/commits to main/master/develop/qa"
  echo "and all force-pushes — enforced for every repo, human and agent alike)"
  echo ""
  echo "  ⚠  This sets your GLOBAL git config core.hooksPath. Existing global hooks are"
  echo "     chained (run first), not discarded. Human override: GIT_GUARD_ALLOW=1."
  echo ""
  read -p "  Install git-guard? [y/N]: " guardchoice
  if [[ "$guardchoice" == "y" || "$guardchoice" == "Y" ]]; then
    install_git_guard
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
