# Code Review

Use when reviewing code changes, PR diffs, or when asked to check code quality.

## Trigger

User asks to "review", "check", "audit code", or provides a diff/file for feedback.

## Process

Dispatch a **pr-reviewer subagent** to perform the review. The subagent has Fallow tools (dead code, complexity, duplication, security) and git tools configured — it handles the full review including automated analysis.

The subagent will:
1. Run fallow `audit` against the diff (dead code, complexity, duplication)
2. Run `security_candidates` on changed source files
3. Review against team conventions and the originating spec (if one exists)
4. Report findings by severity (🔴 blocker / 🟡 warning / 🔵 nit)
5. Produce a handover prompt if blockers are found

If the subagent is not available (e.g., running in a minimal environment), fall back to the manual review checklist below.

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
6. **Accessibility** — Meets WCAG 2.1 AA? Semantic HTML? Keyboard navigable? Screen reader tested? (See below)
7. **Security** — User input sanitised? No secrets exposed? Safe external data handling?
8. **Browser support** — Are Web APIs fully supported in target browsers? (See below)

## Accessibility Check

Accessibility is a first-class concern. Every review must verify:

### Semantic HTML
- Use correct elements for their purpose (`<button>` not `<div onClick>`, `<nav>`, `<main>`, `<article>`, `<aside>`, headings in order)
- Links (`<a>`) for navigation, buttons (`<button>`) for actions — never swap them
- Lists (`<ul>/<ol>`) for groups of related items
- `<table>` for tabular data only (not layout)

### Keyboard Navigation
- All interactive elements reachable via Tab
- Focus order matches visual order
- Custom components (dropdowns, modals, carousels) must trap/manage focus appropriately
- Escape key closes modals/overlays and returns focus to trigger
- No keyboard traps (user can always Tab out)
- Visible focus indicator on all focusable elements (don't remove `:focus` outline without a replacement)

### ARIA
- Prefer native semantics over ARIA (`<button>` over `<div role="button">`)
- If ARIA is needed: correct `role`, `aria-label`/`aria-labelledby`, `aria-expanded`, `aria-hidden`, `aria-live` for dynamic content
- No redundant ARIA (e.g., `<button role="button">` is noise)
- `aria-live="polite"` for status messages, toasts, async content updates

### Images & Media
- All `<img>` must have `alt` (empty `alt=""` for decorative images)
- Icons used as actions need accessible labels (`aria-label` or visually hidden text)
- Video/audio should have captions or transcripts where applicable

### Forms
- Every input has an associated `<label>` (via `htmlFor` or wrapping)
- Error messages linked to inputs via `aria-describedby`
- Required fields indicated via `aria-required` or visible text (not just colour)
- Form validation errors announced to screen readers (via `aria-live` region or focus management)

### Colour & Contrast
- Text meets WCAG AA contrast ratio (4.5:1 for normal text, 3:1 for large text)
- Information not conveyed by colour alone (e.g., error states need icon/text too)
- UI components and graphical objects: 3:1 contrast against adjacent colours

### Motion & Animation
- Respect `prefers-reduced-motion` — disable or reduce animations
- No auto-playing content that can't be paused
- No content that flashes more than 3 times per second

### Severity
- 🔴 **must-fix**: Renders content inaccessible (missing labels, keyboard trap, no focus management, interactive div without role)
- 🟡 **should-fix**: Degraded experience (poor contrast, missing aria-live, focus order confusing but navigable)
- 🔵 **nit**: Best-practice improvement (could use a more specific landmark, redundant ARIA)

## Browser Support Check

When the code uses Web APIs (not language syntax — Babel handles that), verify support:

### When to check
- Direct use of Web APIs: `fetch`, `IntersectionObserver`, `ResizeObserver`, `AbortController`, `navigator.serviceWorker`, `Notification`, `crypto.subtle`, `URLSearchParams`, `structuredClone`, etc.
- CSS features used in styled-components or inline styles that aren't just vendor-prefixed (e.g., `container queries`, `has()`, `@layer`)
- New-ish DOM APIs: `dialog.showModal()`, `Popover API`, `View Transitions`

### How to verify
1. Query MDN via Context7 (`/mdn/content` or `/websites/developer_mozilla_en-us`) for the API's browser compatibility
2. Or `web_fetch` against `https://caniuse.com/?search={feature}` for a quick check
3. Compare against team's target browsers (see below)

### Target browsers
- Chrome/Edge: last 2 major versions
- Safari: last 2 major versions (⚠️ Safari is the usual laggard — pay extra attention)
- Firefox: last 2 major versions
- iOS Safari: last 2 major versions
- No IE11 support required

### What counts as an issue
- 🔴 **must-fix**: API not supported in ANY current version of a target browser (no polyfill, no fallback)
- 🟡 **should-fix**: API has partial support or requires a flag in a target browser — needs a fallback or feature detection
- 🔵 **nit**: API is fully supported but was only added in very recent versions — note it for awareness

### What does NOT need checking
- Language syntax (arrow functions, optional chaining, nullish coalescing) — Babel transpiles these
- Node.js APIs used only in server code (web-server repos)
- APIs already behind a polyfill the project ships (check `webpack.config.js` or `babel.config.js` for polyfill plugins)
- APIs used inside a `try/catch` or feature-detection guard (`if ('serviceWorker' in navigator)`)

## Output Format

For each issue found, state:
- **Severity**: 🔴 must-fix | 🟡 should-fix | 🔵 nit
- **Location**: file + line/section
- **Issue**: What's wrong
- **Suggestion**: How to fix it

End with a summary: overall assessment and whether it's ready to merge.
