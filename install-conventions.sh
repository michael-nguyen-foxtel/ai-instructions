#!/bin/bash
# install-conventions.sh
# Copies convention files from this template into a target project's
# .kiro/steering/ and .github/instructions/ directories.
#
# Usage: ./install-conventions.sh /path/to/your-project

set -e

TARGET="${1:?Usage: ./install-conventions.sh /path/to/your-project}"
SOURCE="$(cd "$(dirname "$0")/docs/conventions" && pwd)"

KIRO_DIR="$TARGET/.kiro/steering"
COPILOT_DIR="$TARGET/.github/instructions"

mkdir -p "$KIRO_DIR" "$COPILOT_DIR"

# Kiro uses plain .md files (no frontmatter needed, but harmless)
for file in "$SOURCE"/*.instructions.md; do
  [ -f "$file" ] || continue
  filename="$(basename "$file")"
  # Kiro: strip .instructions from filename, keep as .md
  kiro_filename="${filename%.instructions.md}.md"
  cp "$file" "$KIRO_DIR/$kiro_filename"
  # Copilot: keep .instructions.md extension
  cp "$file" "$COPILOT_DIR/$filename"
done

echo "✓ Conventions installed:"
echo "  Kiro:    $KIRO_DIR/"
echo "  Copilot: $COPILOT_DIR/"
