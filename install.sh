#!/bin/bash
# install.sh
# Installs Copilot instruction files into a target project's .github/instructions/ directory.
# Does NOT touch .kiro/ — universal skills live at ~/.kiro/skills/ (user-level).
#
# Usage: ./install.sh /path/to/your-project

set -e

TARGET="${1:?Usage: ./install.sh /path/to/your-project}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
COPILOT_SOURCE="$SCRIPT_DIR/copilot"
COPILOT_TARGET="$TARGET/.github/instructions"

mkdir -p "$COPILOT_TARGET"

for file in "$COPILOT_SOURCE"/*.instructions.md; do
  [ -f "$file" ] || continue
  filename="$(basename "$file")"
  cp "$file" "$COPILOT_TARGET/$filename"
done

echo "✓ Copilot instructions installed to: $COPILOT_TARGET/"
ls "$COPILOT_TARGET"
echo ""
echo "Files installed:"
echo "  • commit-messages.instructions.md  — commit format (always-on)"
echo "  • pull-requests.instructions.md    — PR conventions (always-on)"
echo "  • branch-naming.instructions.md    — branch format (always-on)"
echo "  • code-review.instructions.md      — code conventions (always-on)"
echo "  • testing.instructions.md          — test conventions (*.spec.* files only)"
