---
applyTo: "**/*.spec.js,**/*.spec.ts,**/*.spec.tsx,**/*.test.js,**/*.test.ts,**/*.test.tsx"
---

# Testing Conventions

Follow Kent C. Dodds' approach: test behaviour and outcomes, not implementation details.

## Frameworks

- Jest + React Testing Library (RTL)
- Shared config: `@fsa-streamotion/jest-config`
- No E2E tests (no Cypress, Playwright, Puppeteer)
- No snapshot tests unless explicitly asked

## RTL Query Priority

1. `getByRole` — accessible to everyone
2. `getByLabelText` — form fields
3. `getByPlaceholderText` — fallback for inputs
4. `getByText` — non-interactive elements
5. `getByDisplayValue` — filled form elements
6. `getByTestId` — last resort only

Never use `container.querySelector` or DOM traversal.

## Structure

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

## Rules

- Test files: `[name].spec.js` (co-located or in test directory)
- It blocks: `should [do something] when [condition]`
- Mock at the API boundary, not the implementation
- Use `waitFor` or `findBy` for async — never arbitrary timeouts
- Prefer `toBeInTheDocument()`, `toHaveTextContent()`, `toBeVisible()` over manual checks
- Don't mock what you can render — prefer integration over isolation
- Mock external APIs only (use MSW where available)
