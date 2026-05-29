#!/bin/bash
# install-agent-config.sh
# Copies agent skills and steering/instructions from this template into
# a target project's .kiro/ and .github/ directories.
#
# Usage: ./install-agent-config.sh /path/to/your-project

set -e

TARGET="${1:?Usage: ./install-agent-config.sh /path/to/your-project}"
DOCS_DIR="$(cd "$(dirname "$0")/docs" && pwd)"

# --- Skills (on-demand, task-specific) ---
SKILLS_SOURCE="$DOCS_DIR/skills"
KIRO_SKILLS_DIR="$TARGET/.kiro/skills"
COPILOT_SKILLS_DIR="$TARGET/.github/skills"

for skill_dir in "$SKILLS_SOURCE"/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name="$(basename "$skill_dir")"
  mkdir -p "$KIRO_SKILLS_DIR/$skill_name" "$COPILOT_SKILLS_DIR/$skill_name"
  cp "$skill_dir/SKILL.md" "$KIRO_SKILLS_DIR/$skill_name/SKILL.md"
  cp "$skill_dir/SKILL.md" "$COPILOT_SKILLS_DIR/$skill_name/SKILL.md"
done

# --- Conventions (always-on steering/instructions) ---
CONVENTIONS_SOURCE="$DOCS_DIR/conventions"
KIRO_STEERING_DIR="$TARGET/.kiro/steering"
COPILOT_INSTRUCTIONS_DIR="$TARGET/.github/instructions"

for file in "$CONVENTIONS_SOURCE"/*.md; do
  [ -f "$file" ] || continue
  filename="$(basename "$file")"
  # Skip the README — it's not a convention file
  [ "$filename" = "README.md" ] && continue
  mkdir -p "$KIRO_STEERING_DIR" "$COPILOT_INSTRUCTIONS_DIR"
  cp "$file" "$KIRO_STEERING_DIR/$filename"
  cp "$file" "$COPILOT_INSTRUCTIONS_DIR/$filename"
done

echo "✓ Conventions installed:"
echo "  Skills:"
echo "    Kiro:    $KIRO_SKILLS_DIR/"
echo "    Copilot: $COPILOT_SKILLS_DIR/"
echo "  Steering/Instructions:"
echo "    Kiro:    $KIRO_STEERING_DIR/"
echo "    Copilot: $COPILOT_INSTRUCTIONS_DIR/"
