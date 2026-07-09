# Testing Conventions

## Philosophy

Follow Kent C. Dodds' testing approach: write tests as if you are the user. Test behaviour and outcomes, not implementation details.

> "The more your tests resemble the way your software is used, the more confidence they can give you."

## Frameworks

- **Primary**: Jest + React Testing Library (RTL)
- **Legacy/server**: Mocha + Sinon (some repos)
- **Shared config**: `@fsa-streamotion/jest-config`
- **No E2E tests** currently — don't write Cypress/Playwright tests unless explicitly asked

## What to Test

- User-visible behaviour (what happens when they click, type, navigate)
- Component rendering given specific props/state
- Error states and edge cases
- Async flows (loading → success/error)
- Accessibility (elements findable by role, label, text)

## What NOT to Test

- Implementation details (internal state, private methods, hook internals)
- Third-party library behaviour
- Styling/CSS values (unless it's a logic-driven style)
- Snapshot tests (avoid unless there's a strong reason — they're brittle)
- Property/generative tests (e.g. fast-check) — team uses traditional unit + integration tests only
- Tests that require browser execution (no Cypress, Playwright, Puppeteer)
- Tests against live Platform APIs — mock all external boundaries

## RTL Query Priority

Follow RTL's recommended query priority:
1. `getByRole` — accessible to everyone
2. `getByLabelText` — form fields
3. `getByPlaceholderText` — fallback for inputs
4. `getByText` — non-interactive elements
5. `getByDisplayValue` — filled form elements
6. `getByTestId` — last resort only

Never use `container.querySelector` or similar DOM traversal.

## Test Structure

```javascript
describe('ComponentName', () => {
    it('should [expected behaviour] when [condition]', () => {
        // Arrange
        render(<Component prop="value" />);

        // Act
        await userEvent.click(screen.getByRole('button', { name: /submit/i }));

        // Assert
        expect(screen.getByText('Success')).toBeInTheDocument();
    });
});
```

## Naming Convention

- Test files: `[name].spec.js` (co-located or in test directory)
- Describe blocks: Component or function name
- It blocks: `should [do something] when [condition]`

## Mocking Guidelines

- Mock external API calls (use MSW where available — the repo has `mock-service-worker.js`)
- Mock timers for debounce/throttle tests
- Don't mock what you can render — prefer integration over isolation
- If you must mock a hook/module, mock at the boundary (API layer), not the implementation

## Assertions

- Prefer `toBeInTheDocument()` over truthiness checks
- Use `toHaveTextContent()` over checking innerHTML
- Use `toBeVisible()` when testing show/hide behaviour
- Use `waitFor` or `findBy` for async assertions, never arbitrary timeouts
