# Mocking Guidelines

## Philosophy

Mock at the boundary, not the implementation. The boundary is where your code talks to the outside world — APIs, timers, browser APIs. Everything inside that boundary should be exercised for real.

## Where to mock

| Boundary | Mock with | Example |
|----------|-----------|---------|
| HTTP APIs | MSW (`mock-service-worker.js`) or Jest module mocks | API responses |
| Timers | `jest.useFakeTimers()` | Debounce, polling |
| Date/time | `jest.spyOn(Date, 'now')` | Time-dependent logic |
| Browser APIs | Jest globals or jsdom stubs | `window.location`, `localStorage` |

## Where NOT to mock

- Internal modules you own (hooks, utilities, child components)
- React state or lifecycle
- The component you're testing
- Anything you can render and exercise for real

## Rules

1. **Prefer integration over isolation.** Render the full component tree where possible. Only mock what crosses a network or system boundary.
2. **MSW first.** If the repo has `mock-service-worker.js` or an MSW setup, use it. Network-level mocking is more realistic than module mocking.
3. **No mocking hooks.** If you need to mock a hook to test a component, the seam is wrong — test at a higher level or restructure.
4. **Explicit over implicit.** When you must `jest.mock()`, make the mock's return value explicit in the test — don't rely on a default mock buried in a `__mocks__` folder.
5. **Reset between tests.** Use `beforeEach` / `afterEach` to restore mocks. Leaking state between tests is a reliability killer.
