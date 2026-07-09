# Code Review

Use when reviewing code changes, PR diffs, or when asked to check code quality.

## Trigger

User asks to "review", "check", "audit code", or provides a diff/file for feedback.

## Conventions (from @fsa-streamotion/streamotion-web-eslint-config)

### Naming
- **Files**: lowercase kebab-case (`my-component.js`, `use-auth-state.js`)
- **React components**: PascalCase in code, kebab-case filename
- **Boolean props**: Must be prefixed with `is`, `has`, `can`, `was`, `will`, `should`, `did`, or `had` (e.g., `isVisible`, `hasError`)
- **CSS custom properties**: Must match `((quicksilver)|(magneto))-.+`

### React
- Prefer stateless functional components over class components
- Enforce prop-types validation (unless TypeScript)
- Use `<React.Fragment>` over `<>` shorthand
- Buttons must have explicit `type` attribute
- Self-closing components when no children
- No `dangerouslySetInnerHTML`
- No `findDOMNode`, string refs, or deprecated lifecycle methods
- No unstable nested component definitions (unless passed as props via `allowAsProps`)
- JSX curly braces: never for props/children when not needed, always for prop element values
- Max 5 props per line before splitting

### JavaScript
- No parameter reassignment (`no-param-reassign`)
- Strict equality (`===`) with smart exception for null checks
- Always use curly braces for control statements
- No implicit type coercion (except `!!` for boolean)
- Dot notation over bracket notation where possible
- No `eval`, `alert`, or `with`
- No yoda conditions
- Vars declared at top of scope
- `radix` argument only as-needed for `parseInt`

### Imports
- All modules must be unambiguous (explicit ESM or CJS)
- No unused module exports
- CommonJS only in config files (eslint-disable comment required)

### Documentation
- JSDoc encouraged for non-component utility functions
- Relaxed in component files and storybook files

### Styling
- Uses styled-components (postcss-styled-syntax)
- Stylelint enforced via `@fsa-streamotion/streamotion-web-stylelint-config`
- CSS values lowercase (except `currentColor`)

## Review Checklist

When reviewing, check for:

1. **Correctness** — Does it do what it's supposed to? Edge cases?
2. **Convention compliance** — Does it follow the above rules? (ESLint will catch most, but not all)
3. **Readability** — Is intent clear? Would future-you understand this in 6 months?
4. **Testing** — Is the change tested? Are tests testing behaviour, not implementation?
5. **Performance** — Unnecessary re-renders? Missing memoisation where it matters? (Don't over-optimise)
6. **Accessibility** — Semantic HTML? ARIA where needed? Keyboard navigable?
7. **Security** — User input sanitised? No secrets exposed? Safe external data handling?

## Output Format

For each issue found, state:
- **Severity**: 🔴 must-fix | 🟡 should-fix | 🔵 nit
- **Location**: file + line/section
- **Issue**: What's wrong
- **Suggestion**: How to fix it

End with a summary: overall assessment and whether it's ready to merge.
