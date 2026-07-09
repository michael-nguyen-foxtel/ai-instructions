# Tests Reference

Examples of good tests using the project's testing stack.

## Stack

- **Jest** — test runner
- **React Testing Library (RTL)** — component testing
- **userEvent** — interaction simulation
- **MSW / manual mocks** — API boundary mocking

## Query Priority (RTL)

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
    it('should [expected behaviour] when [condition]', async () => {
        // Arrange
        render(<Component prop="value" />);

        // Act
        await userEvent.click(screen.getByRole('button', { name: /submit/i }));

        // Assert
        expect(screen.getByText('Success')).toBeInTheDocument();
    });
});
```

## Naming

- Files: `[name].spec.js` (co-located or in test directory)
- Describe blocks: component or function name
- It blocks: `should [do something] when [condition]`

## Assertions

- `toBeInTheDocument()` over truthiness checks
- `toHaveTextContent()` over checking innerHTML
- `toBeVisible()` for show/hide behaviour
- `waitFor` or `findBy` for async — never arbitrary timeouts

## Good test example (component)

```javascript
describe('LoginForm', () => {
    it('should show error message when credentials are invalid', async () => {
        server.use(
            rest.post('/api/login', (req, res, ctx) =>
                res(ctx.status(401, 'Unauthorized'))
            )
        );

        render(<LoginForm />);

        await userEvent.type(screen.getByLabelText(/email/i), 'bad@email.com');
        await userEvent.type(screen.getByLabelText(/password/i), 'wrong');
        await userEvent.click(screen.getByRole('button', { name: /sign in/i }));

        expect(await screen.findByText(/invalid credentials/i)).toBeInTheDocument();
    });
});
```

## Good test example (utility)

```javascript
describe('formatCurrency', () => {
    it('should format cents as AUD with two decimal places', () => {
        expect(formatCurrency(1999)).toBe('$19.99');
    });

    it('should handle zero', () => {
        expect(formatCurrency(0)).toBe('$0.00');
    });
});
```
