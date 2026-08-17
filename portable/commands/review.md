# Review

Review the current diff (or specified files) for quality, correctness, and conventions.

## Process

1. Read the diff or changed files
2. Check against the criteria below
3. Report findings by severity

## Criteria

### Correctness
- Does it do what it's supposed to?
- Are edge cases handled?
- Are error states handled gracefully?

### Conventions
- Naming: kebab-case files, PascalCase components, boolean props prefixed (`is`, `has`, `can`)
- Code style matches existing patterns in the repo
- No unnecessary abstractions or over-engineering

### Testing
- Are changes tested?
- Do tests test behaviour (not implementation)?
- Are async flows tested (loading → success/error)?

### Accessibility
- Semantic HTML (button for actions, a for navigation)
- Keyboard navigable
- ARIA attributes where needed
- Colour contrast sufficient
- Information not conveyed by colour alone

### Performance
- No unnecessary re-renders
- No missing cleanup (event listeners, timers, subscriptions)
- Large lists virtualised if needed

### Security
- User input sanitised
- No secrets exposed
- External data handled safely

### Browser support
- Web APIs supported in last 2 versions of Chrome, Safari, Firefox
- Safari is the usual laggard — flag unsupported APIs

## Output Format

For each finding:
- 🔴 **must-fix**: Blocks merge (broken behaviour, inaccessible, security issue)
- 🟡 **should-fix**: Degraded quality (poor naming, missing test, edge case)
- 🔵 **nit**: Suggestion (style preference, minor improvement)

End with: overall assessment and whether it's ready to merge.
