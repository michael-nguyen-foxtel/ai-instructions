---
applyTo: "**"
---

# Code Review Conventions

## Naming

- **Files**: lowercase kebab-case (`my-component.js`, `use-auth-state.js`)
- **React components**: PascalCase in code, kebab-case filename
- **Boolean props**: prefixed with `is`, `has`, `can`, `was`, `will`, `should`, `did`, or `had`
- **CSS custom properties**: must match `((quicksilver)|(magneto))-.+`

## React

- Prefer stateless functional components over class components
- Buttons must have explicit `type` attribute
- Self-closing components when no children
- No `dangerouslySetInnerHTML`
- No `findDOMNode`, string refs, or deprecated lifecycle methods
- JSX curly braces: never for props/children when not needed
- Max 5 props per line before splitting

## JavaScript

- No parameter reassignment (`no-param-reassign`)
- Strict equality (`===`) with smart exception for null checks
- Always use curly braces for control statements
- Dot notation over bracket notation where possible
- No `eval`, `alert`, or `with`

## Imports

- All modules must be unambiguous (explicit ESM or CJS)
- CommonJS only in config files

## Styling

- Uses styled-components
- CSS values lowercase (except `currentColor`)

## Accessibility

- Use correct semantic elements (`<button>` not `<div onClick>`)
- Links for navigation, buttons for actions
- All interactive elements keyboard-reachable
- All `<img>` must have `alt` (empty `alt=""` for decorative)
- Every input has an associated `<label>`
- Text meets WCAG AA contrast (4.5:1 normal, 3:1 large)
- Respect `prefers-reduced-motion`
- Visible focus indicator on all focusable elements
